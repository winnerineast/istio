// Copyright 2017 Istio Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package na

import (
	"bytes"
	"fmt"
	"net"
	"testing"
	"time"

	"github.com/golang/glog"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	rpc "istio.io/gogo-genproto/googleapis/google/rpc"
	"istio.io/istio/security/pkg/platform"
	mockpc "istio.io/istio/security/pkg/platform/mock"
	mockutil "istio.io/istio/security/pkg/util/mock"
	"istio.io/istio/security/pkg/workload"
	pb "istio.io/istio/security/proto"
	"strings"
)

const (
	maxCAClientSuccessReturns = 8
)

type FakeCAClient struct {
	Counter  int
	response *pb.Response
	err      error
}

func (f *FakeCAClient) SendCSR(req *pb.Request, pc platform.Client, cfg *Config) (*pb.Response, error) {
	f.Counter++
	if f.Counter > maxCAClientSuccessReturns {
		return nil, fmt.Errorf("terminating the test with errors")
	}
	return f.response, f.err
}

type FakeIstioCAGrpcServer struct {
	IsApproved      bool
	Status          *rpc.Status
	SignedCertChain []byte

	response *pb.Response
	errorMsg string
}

func (s *FakeIstioCAGrpcServer) SetResponseAndError(response *pb.Response, errorMsg string) {
	s.response = response
	s.errorMsg = errorMsg
}

func (s *FakeIstioCAGrpcServer) HandleCSR(ctx context.Context, req *pb.Request) (*pb.Response, error) {
	if len(s.errorMsg) > 0 {
		return nil, fmt.Errorf(s.errorMsg)
	}

	return s.response, nil
}

type FakeCertUtil struct {
	duration time.Duration
	err      error
}

func (f FakeCertUtil) GetWaitTime(certBytes []byte, now time.Time, gracePeriodPercentage int) (time.Duration, error) {
	if f.err != nil {
		return time.Duration(0), f.err
	}
	return f.duration, nil
}

func TestStartWithArgs(t *testing.T) {
	generalPcConfig := platform.ClientConfig{OnPremConfig: platform.OnPremConfig{"ca_file", "pkey", "cert_file"}}
	generalConfig := Config{
		"ca_addr", "Google Inc.", 512, "onprem", time.Millisecond, 3, 50, generalPcConfig,
	}
	testCases := map[string]struct {
		config      *Config
		pc          platform.Client
		cAClient    *FakeCAClient
		certUtil    FakeCertUtil
		expectedErr string
		sendTimes   int
		fileContent []byte
	}{
		"Success": {
			config:      &generalConfig,
			pc:          mockpc.FakeClient{nil, "", "service1", "", []byte{}, "", true},
			cAClient:    &FakeCAClient{0, &pb.Response{IsApproved: true, SignedCertChain: []byte(`TESTCERT`)}, nil},
			certUtil:    FakeCertUtil{time.Duration(0), nil},
			expectedErr: "node agent can't get the CSR approved from Istio CA after max number of retries (3)",
			sendTimes:   12,
			fileContent: []byte(`TESTCERT`),
		},
		"Config Nil error": {
			pc:          mockpc.FakeClient{nil, "", "service1", "", []byte{}, "", true},
			cAClient:    &FakeCAClient{0, nil, nil},
			expectedErr: "node Agent configuration is nil",
			sendTimes:   0,
		},
		"Platform error": {
			config:      &generalConfig,
			pc:          mockpc.FakeClient{nil, "", "service1", "", []byte{}, "", false},
			cAClient:    &FakeCAClient{0, nil, nil},
			expectedErr: "node Agent is not running on the right platform",
			sendTimes:   0,
		},
		"Create CSR error": {
			// 128 is too small for a RSA private key. GenCSR will return error.
			config: &Config{
				"ca_addr", "Google Inc.", 128, "onprem", time.Millisecond, 3, 50, generalPcConfig,
			},
			pc:       mockpc.FakeClient{nil, "", "service1", "", []byte{}, "", true},
			cAClient: &FakeCAClient{0, nil, nil},
			expectedErr: "request creation fails on CSR generation (CSR generation fails at X509 cert request " +
				"generation (crypto/rsa: message too long for RSA public key size))",
			sendTimes: 0,
		},
		"Getting agent credential error": {
			config:      &generalConfig,
			pc:          mockpc.FakeClient{nil, "", "service1", "", nil, "Err1", true},
			cAClient:    &FakeCAClient{0, nil, nil},
			expectedErr: "request creation fails on getting agent credential (Err1)",
			sendTimes:   0,
		},
		"SendCSR empty response error": {
			config:      &generalConfig,
			pc:          mockpc.FakeClient{nil, "", "service1", "", []byte{}, "", true},
			cAClient:    &FakeCAClient{0, nil, nil},
			expectedErr: "node agent can't get the CSR approved from Istio CA after max number of retries (3)",
			sendTimes:   4,
		},
		"SendCSR returns error": {
			config:      &generalConfig,
			pc:          mockpc.FakeClient{nil, "", "service1", "", []byte{}, "", true},
			cAClient:    &FakeCAClient{0, nil, fmt.Errorf("error returned from CA")},
			expectedErr: "node agent can't get the CSR approved from Istio CA after max number of retries (3)",
			sendTimes:   4,
		},
		"SendCSR not approved": {
			config:      &generalConfig,
			pc:          mockpc.FakeClient{nil, "", "service1", "", []byte{}, "", true},
			cAClient:    &FakeCAClient{0, &pb.Response{IsApproved: false}, nil},
			expectedErr: "node agent can't get the CSR approved from Istio CA after max number of retries (3)",
			sendTimes:   4,
		},
		"SendCSR parsing error": {
			config:      &generalConfig,
			pc:          mockpc.FakeClient{nil, "", "service1", "", []byte{}, "", true},
			cAClient:    &FakeCAClient{0, &pb.Response{IsApproved: true, SignedCertChain: []byte(`TESTCERT`)}, nil},
			certUtil:    FakeCertUtil{time.Duration(0), fmt.Errorf("cert parsing error")},
			expectedErr: "node agent can't get the CSR approved from Istio CA after max number of retries (3)",
			sendTimes:   4,
		},
	}

	for id, c := range testCases {
		glog.Errorf("Start to test %s", id)
		fakeFileUtil := mockutil.FakeFileUtil{
			ReadContent:  make(map[string][]byte),
			WriteContent: make(map[string][]byte),
		}
		fakeWorkloadIO, _ := workload.NewSecretServer(
			workload.Config{
				Mode:                          workload.SecretFile,
				FileUtil:                      fakeFileUtil,
				ServiceIdentityCertFile:       "cert_file",
				ServiceIdentityPrivateKeyFile: "key_file",
			},
		)
		na := nodeAgentInternal{c.config, c.pc, c.cAClient, "service1", fakeWorkloadIO, c.certUtil}
		err := na.Start()
		if err.Error() != c.expectedErr {
			t.Errorf("Test case [%s]: incorrect error message: %s VS (expected) %s", id, err.Error(), c.expectedErr)
		}
		if c.cAClient.Counter != c.sendTimes {
			t.Errorf("Test case [%s]: sendCSR is called incorrect times: %d VS (expected) %d",
				id, c.cAClient.Counter, c.sendTimes)
		}
		if c.fileContent != nil && !bytes.Equal(fakeFileUtil.WriteContent["cert_file"], c.fileContent) {
			t.Errorf("Test case [%s]: cert file content incorrect: %s VS (expected) %s",
				id, fakeFileUtil.WriteContent["cert_file"], c.fileContent)
		}
	}
}

func TestSendCSRAgainstLocalInstance(t *testing.T) {
	// create a local grpc server
	s := grpc.NewServer()
	lis, err := net.Listen("tcp", "localhost:0")
	if err != nil {
		t.Errorf("failed to listen: %v", err)
	}
	serv := FakeIstioCAGrpcServer{}

	go func() {
		defer func() {
			s.Stop()
		}()
		pb.RegisterIstioCAServiceServer(s, &serv)
		reflection.Register(s)
		if err := s.Serve(lis); err != nil {
			t.Errorf("failed to serve: %v", err)
		}
	}()

	// The goroutine starting the server may not be ready, results in flakiness.
	time.Sleep(1 * time.Second)

	defaultServerResponse := pb.Response{
		IsApproved:      true,
		Status:          &rpc.Status{Code: int32(rpc.OK), Message: "OK"},
		SignedCertChain: nil,
	}

	testCases := map[string]struct {
		config      *Config
		pc          platform.Client
		res         pb.Response
		resErr      string
		cAClient    *cAGrpcClientImpl
		expectedErr string
		certUtil    FakeCertUtil
	}{
		"IstioCAAddress is empty": {
			config: &Config{
				IstioCAAddress: "",
				RSAKeySize:     512,
			},
			pc: mockpc.FakeClient{[]grpc.DialOption{
				grpc.WithInsecure(),
			}, "", "service1", "", []byte{}, "", true},
			res:         defaultServerResponse,
			cAClient:    &cAGrpcClientImpl{},
			expectedErr: "istio CA address is empty",
		},
		"IstioCAAddress is incorrect": {
			config: &Config{
				IstioCAAddress: lis.Addr().String() + "1",
				RSAKeySize:     512,
			},
			pc: mockpc.FakeClient{[]grpc.DialOption{
				grpc.WithInsecure(),
			}, "", "service1", "", []byte{}, "", true},
			res:         defaultServerResponse,
			cAClient:    &cAGrpcClientImpl{},
			expectedErr: "CSR request failed rpc error: code = Unavailable",
		},
		"Without Insecure option": {
			config: &Config{
				IstioCAAddress: lis.Addr().String(),
				RSAKeySize:     512,
			},
			pc:       mockpc.FakeClient{[]grpc.DialOption{}, "", "service1", "", []byte{}, "", true},
			res:      defaultServerResponse,
			cAClient: &cAGrpcClientImpl{},
			expectedErr: fmt.Sprintf("failed to dial %s: grpc: no transport security set "+
				"(use grpc.WithInsecure() explicitly or set credentials)", lis.Addr().String()),
		},
		"Error from GetDialOptions": {
			config: &Config{
				IstioCAAddress: lis.Addr().String(),
				RSAKeySize:     512,
			},
			pc: mockpc.FakeClient{[]grpc.DialOption{
				grpc.WithInsecure(),
			}, "Error from GetDialOptions", "service1", "", []byte{}, "", true},
			res:         defaultServerResponse,
			cAClient:    &cAGrpcClientImpl{},
			expectedErr: "Error from GetDialOptions",
		},
		"SendCSR not approved": {
			config: &Config{
				IstioCAAddress: lis.Addr().String(),
				RSAKeySize:     512,
			},
			pc: mockpc.FakeClient{[]grpc.DialOption{
				grpc.WithInsecure(),
			}, "", "service1", "", []byte{}, "", true},
			res:         defaultServerResponse,
			cAClient:    &cAGrpcClientImpl{},
			expectedErr: "",
		},
	}

	for id, c := range testCases {
		fakeFileUtil := mockutil.FakeFileUtil{
			ReadContent:  make(map[string][]byte),
			WriteContent: make(map[string][]byte),
		}

		fakeWorkloadIO, _ := workload.NewSecretServer(
			workload.Config{
				Mode:                          workload.SecretFile,
				FileUtil:                      fakeFileUtil,
				ServiceIdentityCertFile:       "cert_file",
				ServiceIdentityPrivateKeyFile: "key_file",
			},
		)

		na := nodeAgentInternal{c.config, c.pc, c.cAClient, "service1", fakeWorkloadIO, c.certUtil}

		serv.SetResponseAndError(&c.res, c.resErr)

		_, req, _ := na.createRequest()
		_, err := na.cAClient.SendCSR(req, na.pc, na.config)
		if len(c.expectedErr) > 0 {
			if err == nil {
				t.Errorf("Error expected: %v", c.expectedErr)
			} else if ! strings.Contains(err.Error(), c.expectedErr) {
				t.Errorf("%s: incorrect error message: got [%s] VS want [%s]", id, err.Error(), c.expectedErr)
			}
		} else {
			if err != nil {
				t.Errorf("Unexpected expected: %v", err)
			}
		}
	}
}
