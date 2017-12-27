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

package util

import (
	"context"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/golang/glog"
	"github.com/google/go-github/github"
)

const (
	testSrcDir     = "TEST_SRCDIR"
	pathPrefix     = "io_istio_istio"
	runfilesSuffix = ".runfiles"
)

// GetHeadCommitSHA finds the SHA of the commit to which the HEAD of branch points
func GetHeadCommitSHA(org, repo, branch string) (string, error) {
	client := github.NewClient(nil)
	githubRefObj, _, err := client.Git.GetRef(
		context.Background(), org, repo, "refs/heads/"+branch)
	if err != nil {
		log.Printf("Failed to get reference SHA of branch [%s]on repo [%s]\n", branch, repo)
		return "", err
	}
	return *githubRefObj.Object.SHA, nil
}

// WriteTextFile overwrites the file on the given path with content
func WriteTextFile(filePath, content string) error {
	if len(content) > 0 && content[len(content)-1] != '\n' {
		content += "\n"
	}
	return ioutil.WriteFile(filePath, []byte(content), 0600)
}

// GitRootDir returns the absolute path to the root directory of the git repo
// where this function is called
func GitRootDir() (string, error) {
	dir, err := Shell("git rev-parse --show-toplevel")
	if err != nil {
		return "", err
	}
	return strings.Trim(dir, "\n"), nil
}

// Poll executes do() after time interval for a max of numTrials times.
// The bool returned by do() indicates if polling succeeds in that trial
func Poll(interval time.Duration, numTrials int, do func() (bool, error)) error {
	if numTrials < 0 {
		return fmt.Errorf("numTrials cannot be negative")
	}
	for i := 0; i < numTrials; i++ {
		if success, err := do(); err != nil {
			return fmt.Errorf("error during trial %d: %v", i, err)
		} else if success {
			return nil
		} else {
			time.Sleep(interval)
		}
	}
	return fmt.Errorf("max polling iteration reached")
}

// CreateTempfile creates a tempfile string.
func CreateTempfile(tmpDir, prefix, suffix string) (string, error) {
	f, err := ioutil.TempFile(tmpDir, prefix)
	if err != nil {
		return "", err
	}
	var tmpName string
	if tmpName, err = filepath.Abs(f.Name()); err != nil {
		return "", err
	}
	if err = f.Close(); err != nil {
		return "", err
	}
	if err = os.Remove(tmpName); err != nil {
		glog.Errorf("CreateTempfile unable to remove %s", tmpName)
		return "", err
	}
	return tmpName + suffix, nil
}

// WriteTempfile creates a tempfile with the specified contents.
func WriteTempfile(tmpDir, prefix, suffix, contents string) (string, error) {
	fname, err := CreateTempfile(tmpDir, prefix, suffix)
	if err != nil {
		return "", err
	}

	if err := ioutil.WriteFile(fname, []byte(contents), 0644); err != nil {
		return "", err
	}
	return fname, nil
}

// Shell run command on shell and get back output and error if get one
func Shell(format string, args ...interface{}) (string, error) {
	return sh(format, true, args...)
}

// ShellMuteOutput run command on shell and get back output and error if get one
// without logging the output
func ShellMuteOutput(format string, args ...interface{}) (string, error) {
	return sh(format, false, args...)
}

func sh(format string, logOutput bool, args ...interface{}) (string, error) {
	command := fmt.Sprintf(format, args...)
	glog.V(2).Infof("Running command %s", command)
	c := exec.Command("sh", "-c", command) // #nosec
	bytes, err := c.CombinedOutput()
	if logOutput {
		glog.V(2).Infof("Command output: \n %s, err: %v", string(bytes[:]), err)
	}
	if err != nil {
		return string(bytes), fmt.Errorf("command failed: %q %v", string(bytes), err)
	}
	return string(bytes), nil
}

// RunBackground starts a background process and return the Process if succeed
func RunBackground(format string, args ...interface{}) (*os.Process, error) {
	command := fmt.Sprintf(format, args...)
	glog.Info("RunBackground: ", command)
	parts := strings.Split(command, " ")
	c := exec.Command(parts[0], parts[1:]...) // #nosec
	err := c.Start()
	if err != nil {
		glog.Errorf("%s, command failed!", command)
		return nil, err
	}
	return c.Process, nil
}

// Record run command and record output into a file
func Record(command, record string) error {
	resp, err := Shell(command)
	if err != nil {
		return err
	}
	err = ioutil.WriteFile(record, []byte(resp), 0600)
	return err
}

// HTTPDownload download from src(url) and store into dst(local file)
func HTTPDownload(dst string, src string) error {
	glog.Infof("Start downloading from %s to %s ...\n", src, dst)
	var err error
	var out *os.File
	var resp *http.Response
	out, err = os.Create(dst)
	if err != nil {
		return err
	}
	defer func() {
		if err = out.Close(); err != nil {
			glog.Errorf("Error: close file %s, %s", dst, err)
		}
	}()
	resp, err = http.Get(src)
	if err != nil {
		return err
	}
	defer func() {
		if err = resp.Body.Close(); err != nil {
			glog.Errorf("Error: close downloaded file from %s, %s", src, err)
		}
	}()
	if resp.StatusCode != 200 {
		return fmt.Errorf("http get request, received unexpected response status: %s", resp.Status)
	}
	if _, err = io.Copy(out, resp.Body); err != nil {
		return err
	}
	glog.Info("Download successfully!")
	return err
}

// CopyFile create a new file to src based on dst
func CopyFile(src, dst string) error {
	var in, out *os.File
	var err error
	in, err = os.Open(src)
	if err != nil {
		return err
	}
	defer func() {
		if err = in.Close(); err != nil {
			glog.Errorf("Error: close file from %s, %s", src, err)
		}
	}()
	out, err = os.Create(dst)
	if err != nil {
		return err
	}
	defer func() {
		if err = out.Close(); err != nil {
			glog.Errorf("Error: close file from %s, %s", dst, err)
		}
	}()
	if _, err = io.Copy(out, in); err != nil {
		return err
	}
	err = out.Sync()
	return err
}

// GetResourcePath give "path from WORKSPACE", return absolute path at runtime
func GetResourcePath(p string) string {
	if dir, exists := os.LookupEnv("GOPATH"); exists {
		return filepath.Join(dir, "src/istio.io/istio", p)
	}
	if dir, exists := os.LookupEnv(testSrcDir); exists {
		return filepath.Join(dir, "workspace", p)
	}
	binPath, err := os.Executable()
	if err != nil {
		glog.Warning("Cannot find excutable path")
		return p
	}
	return filepath.Join(binPath+runfilesSuffix, pathPrefix, p)
}
