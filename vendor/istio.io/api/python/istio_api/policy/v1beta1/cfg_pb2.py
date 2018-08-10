# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: policy/v1beta1/cfg.proto

import sys
_b=sys.version_info[0]<3 and (lambda x:x) or (lambda x:x.encode('latin1'))
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from google.protobuf import reflection as _reflection
from google.protobuf import symbol_database as _symbol_database
from google.protobuf import descriptor_pb2
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()


from google.protobuf import struct_pb2 as google_dot_protobuf_dot_struct__pb2
from policy.v1beta1 import value_type_pb2 as policy_dot_v1beta1_dot_value__type__pb2


DESCRIPTOR = _descriptor.FileDescriptor(
  name='policy/v1beta1/cfg.proto',
  package='istio.policy.v1beta1',
  syntax='proto3',
  serialized_pb=_b('\n\x18policy/v1beta1/cfg.proto\x12\x14istio.policy.v1beta1\x1a\x1cgoogle/protobuf/struct.proto\x1a\x1fpolicy/v1beta1/value_type.proto\"\xc5\x02\n\x11\x41ttributeManifest\x12\x10\n\x08revision\x18\x01 \x01(\t\x12\x0c\n\x04name\x18\x02 \x01(\t\x12K\n\nattributes\x18\x03 \x03(\x0b\x32\x37.istio.policy.v1beta1.AttributeManifest.AttributesEntry\x1aY\n\rAttributeInfo\x12\x13\n\x0b\x64\x65scription\x18\x01 \x01(\t\x12\x33\n\nvalue_type\x18\x02 \x01(\x0e\x32\x1f.istio.policy.v1beta1.ValueType\x1ah\n\x0f\x41ttributesEntry\x12\x0b\n\x03key\x18\x01 \x01(\t\x12\x44\n\x05value\x18\x02 \x01(\x0b\x32\x35.istio.policy.v1beta1.AttributeManifest.AttributeInfo:\x02\x38\x01\"D\n\x04Rule\x12\r\n\x05match\x18\x01 \x01(\t\x12-\n\x07\x61\x63tions\x18\x02 \x03(\x0b\x32\x1c.istio.policy.v1beta1.Action\",\n\x06\x41\x63tion\x12\x0f\n\x07handler\x18\x02 \x01(\t\x12\x11\n\tinstances\x18\x03 \x03(\t\"q\n\x08Instance\x12\x0c\n\x04name\x18\x01 \x01(\t\x12\x1c\n\x11\x63ompiled_template\x18\xf4\xed\xa9  \x01(\t\x12\x10\n\x08template\x18\x02 \x01(\t\x12\'\n\x06params\x18\x03 \x01(\x0b\x32\x17.google.protobuf.Struct\"\xa4\x01\n\x07Handler\x12\x0c\n\x04name\x18\x01 \x01(\t\x12\x1b\n\x10\x63ompiled_adapter\x18\xf4\xed\xa9  \x01(\t\x12\x0f\n\x07\x61\x64\x61pter\x18\x02 \x01(\t\x12\'\n\x06params\x18\x03 \x01(\x0b\x32\x17.google.protobuf.Struct\x12\x34\n\nconnection\x18\x04 \x01(\x0b\x32 .istio.policy.v1beta1.Connection\"\x1d\n\nConnection\x12\x0f\n\x07\x61\x64\x64ress\x18\x02 \x01(\tB\x1dZ\x1bistio.io/api/policy/v1beta1b\x06proto3')
  ,
  dependencies=[google_dot_protobuf_dot_struct__pb2.DESCRIPTOR,policy_dot_v1beta1_dot_value__type__pb2.DESCRIPTOR,])




_ATTRIBUTEMANIFEST_ATTRIBUTEINFO = _descriptor.Descriptor(
  name='AttributeInfo',
  full_name='istio.policy.v1beta1.AttributeManifest.AttributeInfo',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='description', full_name='istio.policy.v1beta1.AttributeManifest.AttributeInfo.description', index=0,
      number=1, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='value_type', full_name='istio.policy.v1beta1.AttributeManifest.AttributeInfo.value_type', index=1,
      number=2, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=244,
  serialized_end=333,
)

_ATTRIBUTEMANIFEST_ATTRIBUTESENTRY = _descriptor.Descriptor(
  name='AttributesEntry',
  full_name='istio.policy.v1beta1.AttributeManifest.AttributesEntry',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='key', full_name='istio.policy.v1beta1.AttributeManifest.AttributesEntry.key', index=0,
      number=1, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='value', full_name='istio.policy.v1beta1.AttributeManifest.AttributesEntry.value', index=1,
      number=2, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  options=_descriptor._ParseOptions(descriptor_pb2.MessageOptions(), _b('8\001')),
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=335,
  serialized_end=439,
)

_ATTRIBUTEMANIFEST = _descriptor.Descriptor(
  name='AttributeManifest',
  full_name='istio.policy.v1beta1.AttributeManifest',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='revision', full_name='istio.policy.v1beta1.AttributeManifest.revision', index=0,
      number=1, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='name', full_name='istio.policy.v1beta1.AttributeManifest.name', index=1,
      number=2, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='attributes', full_name='istio.policy.v1beta1.AttributeManifest.attributes', index=2,
      number=3, type=11, cpp_type=10, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[_ATTRIBUTEMANIFEST_ATTRIBUTEINFO, _ATTRIBUTEMANIFEST_ATTRIBUTESENTRY, ],
  enum_types=[
  ],
  options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=114,
  serialized_end=439,
)


_RULE = _descriptor.Descriptor(
  name='Rule',
  full_name='istio.policy.v1beta1.Rule',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='match', full_name='istio.policy.v1beta1.Rule.match', index=0,
      number=1, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='actions', full_name='istio.policy.v1beta1.Rule.actions', index=1,
      number=2, type=11, cpp_type=10, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=441,
  serialized_end=509,
)


_ACTION = _descriptor.Descriptor(
  name='Action',
  full_name='istio.policy.v1beta1.Action',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='handler', full_name='istio.policy.v1beta1.Action.handler', index=0,
      number=2, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='instances', full_name='istio.policy.v1beta1.Action.instances', index=1,
      number=3, type=9, cpp_type=9, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=511,
  serialized_end=555,
)


_INSTANCE = _descriptor.Descriptor(
  name='Instance',
  full_name='istio.policy.v1beta1.Instance',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='name', full_name='istio.policy.v1beta1.Instance.name', index=0,
      number=1, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='compiled_template', full_name='istio.policy.v1beta1.Instance.compiled_template', index=1,
      number=67794676, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='template', full_name='istio.policy.v1beta1.Instance.template', index=2,
      number=2, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='params', full_name='istio.policy.v1beta1.Instance.params', index=3,
      number=3, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=557,
  serialized_end=670,
)


_HANDLER = _descriptor.Descriptor(
  name='Handler',
  full_name='istio.policy.v1beta1.Handler',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='name', full_name='istio.policy.v1beta1.Handler.name', index=0,
      number=1, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='compiled_adapter', full_name='istio.policy.v1beta1.Handler.compiled_adapter', index=1,
      number=67794676, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='adapter', full_name='istio.policy.v1beta1.Handler.adapter', index=2,
      number=2, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='params', full_name='istio.policy.v1beta1.Handler.params', index=3,
      number=3, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='connection', full_name='istio.policy.v1beta1.Handler.connection', index=4,
      number=4, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=673,
  serialized_end=837,
)


_CONNECTION = _descriptor.Descriptor(
  name='Connection',
  full_name='istio.policy.v1beta1.Connection',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='address', full_name='istio.policy.v1beta1.Connection.address', index=0,
      number=2, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=839,
  serialized_end=868,
)

_ATTRIBUTEMANIFEST_ATTRIBUTEINFO.fields_by_name['value_type'].enum_type = policy_dot_v1beta1_dot_value__type__pb2._VALUETYPE
_ATTRIBUTEMANIFEST_ATTRIBUTEINFO.containing_type = _ATTRIBUTEMANIFEST
_ATTRIBUTEMANIFEST_ATTRIBUTESENTRY.fields_by_name['value'].message_type = _ATTRIBUTEMANIFEST_ATTRIBUTEINFO
_ATTRIBUTEMANIFEST_ATTRIBUTESENTRY.containing_type = _ATTRIBUTEMANIFEST
_ATTRIBUTEMANIFEST.fields_by_name['attributes'].message_type = _ATTRIBUTEMANIFEST_ATTRIBUTESENTRY
_RULE.fields_by_name['actions'].message_type = _ACTION
_INSTANCE.fields_by_name['params'].message_type = google_dot_protobuf_dot_struct__pb2._STRUCT
_HANDLER.fields_by_name['params'].message_type = google_dot_protobuf_dot_struct__pb2._STRUCT
_HANDLER.fields_by_name['connection'].message_type = _CONNECTION
DESCRIPTOR.message_types_by_name['AttributeManifest'] = _ATTRIBUTEMANIFEST
DESCRIPTOR.message_types_by_name['Rule'] = _RULE
DESCRIPTOR.message_types_by_name['Action'] = _ACTION
DESCRIPTOR.message_types_by_name['Instance'] = _INSTANCE
DESCRIPTOR.message_types_by_name['Handler'] = _HANDLER
DESCRIPTOR.message_types_by_name['Connection'] = _CONNECTION
_sym_db.RegisterFileDescriptor(DESCRIPTOR)

AttributeManifest = _reflection.GeneratedProtocolMessageType('AttributeManifest', (_message.Message,), dict(

  AttributeInfo = _reflection.GeneratedProtocolMessageType('AttributeInfo', (_message.Message,), dict(
    DESCRIPTOR = _ATTRIBUTEMANIFEST_ATTRIBUTEINFO,
    __module__ = 'policy.v1beta1.cfg_pb2'
    # @@protoc_insertion_point(class_scope:istio.policy.v1beta1.AttributeManifest.AttributeInfo)
    ))
  ,

  AttributesEntry = _reflection.GeneratedProtocolMessageType('AttributesEntry', (_message.Message,), dict(
    DESCRIPTOR = _ATTRIBUTEMANIFEST_ATTRIBUTESENTRY,
    __module__ = 'policy.v1beta1.cfg_pb2'
    # @@protoc_insertion_point(class_scope:istio.policy.v1beta1.AttributeManifest.AttributesEntry)
    ))
  ,
  DESCRIPTOR = _ATTRIBUTEMANIFEST,
  __module__ = 'policy.v1beta1.cfg_pb2'
  # @@protoc_insertion_point(class_scope:istio.policy.v1beta1.AttributeManifest)
  ))
_sym_db.RegisterMessage(AttributeManifest)
_sym_db.RegisterMessage(AttributeManifest.AttributeInfo)
_sym_db.RegisterMessage(AttributeManifest.AttributesEntry)

Rule = _reflection.GeneratedProtocolMessageType('Rule', (_message.Message,), dict(
  DESCRIPTOR = _RULE,
  __module__ = 'policy.v1beta1.cfg_pb2'
  # @@protoc_insertion_point(class_scope:istio.policy.v1beta1.Rule)
  ))
_sym_db.RegisterMessage(Rule)

Action = _reflection.GeneratedProtocolMessageType('Action', (_message.Message,), dict(
  DESCRIPTOR = _ACTION,
  __module__ = 'policy.v1beta1.cfg_pb2'
  # @@protoc_insertion_point(class_scope:istio.policy.v1beta1.Action)
  ))
_sym_db.RegisterMessage(Action)

Instance = _reflection.GeneratedProtocolMessageType('Instance', (_message.Message,), dict(
  DESCRIPTOR = _INSTANCE,
  __module__ = 'policy.v1beta1.cfg_pb2'
  # @@protoc_insertion_point(class_scope:istio.policy.v1beta1.Instance)
  ))
_sym_db.RegisterMessage(Instance)

Handler = _reflection.GeneratedProtocolMessageType('Handler', (_message.Message,), dict(
  DESCRIPTOR = _HANDLER,
  __module__ = 'policy.v1beta1.cfg_pb2'
  # @@protoc_insertion_point(class_scope:istio.policy.v1beta1.Handler)
  ))
_sym_db.RegisterMessage(Handler)

Connection = _reflection.GeneratedProtocolMessageType('Connection', (_message.Message,), dict(
  DESCRIPTOR = _CONNECTION,
  __module__ = 'policy.v1beta1.cfg_pb2'
  # @@protoc_insertion_point(class_scope:istio.policy.v1beta1.Connection)
  ))
_sym_db.RegisterMessage(Connection)


DESCRIPTOR.has_options = True
DESCRIPTOR._options = _descriptor._ParseOptions(descriptor_pb2.FileOptions(), _b('Z\033istio.io/api/policy/v1beta1'))
_ATTRIBUTEMANIFEST_ATTRIBUTESENTRY.has_options = True
_ATTRIBUTEMANIFEST_ATTRIBUTESENTRY._options = _descriptor._ParseOptions(descriptor_pb2.MessageOptions(), _b('8\001'))
# @@protoc_insertion_point(module_scope)
