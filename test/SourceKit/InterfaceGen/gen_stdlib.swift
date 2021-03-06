
var x: Int

// RUN: %sourcekitd-test -req=interface-gen -module Swift -check-interface-ascii > %t.response
// RUN: FileCheck -check-prefix=CHECK-STDLIB -input-file %t.response %s
// RUN: FileCheck -check-prefix=CHECK-MUTATING-ATTR -input-file %t.response %s
// RUN: FileCheck -check-prefix=CHECK-HIDE-ATTR -input-file %t.response %s

// Just check a small part, mainly to make sure we can print the interface of the stdlib.
// CHECK-STDLIB-NOT: extension _SwiftNSOperatingSystemVersion
// CHECK-STDLIB: struct Int : SignedIntegerType, Comparable, Equatable {
// CHECK-STDLIB:   static var max: Int { get }
// CHECK-STDLIB:   static var min: Int { get }
// CHECK-STDLIB: }

// Check that extensions of nested decls are showing up.
// CHECK-STDLIB-LABEL: extension String.UTF16View.Index {
// CHECK-STDLIB: func samePositionIn(utf8: String.UTF8View) -> String.UTF8View.Index?
// CHECK-STDLIB: func samePositionIn(unicodeScalars: String.UnicodeScalarView) -> UnicodeScalarIndex?
// CHECK-STDLIB: func samePositionIn(characters: String) -> Index?
// CHECK-STDLIB-NEXT: }

// CHECK-MUTATING-ATTR: mutating func

// CHECK-HIDE-ATTR-NOT: @effects
// CHECK-HIDE-ATTR-NOT: @semantics
// CHECK-HIDE-ATTR-NOT: @inline

// RUN: %sourcekitd-test -req=interface-gen-open -module Swift \
// RUN:   == -req=cursor -pos=2:8 %s -- %s | FileCheck -check-prefix=CHECK1 %s

// CHECK1:      source.lang.swift.ref.struct ()
// CHECK1-NEXT: Int
// CHECK1-NEXT: s:Si
// CHECK1-NEXT: Int.Type
// CHECK1-NEXT: Swift{{$}}
// CHECK1-NEXT: <Group>Math</Group>
// CHECK1-NEXT: /<interface-gen>{{$}}
// CHECK1-NEXT: SYSTEM
// CHECK1-NEXT: <Declaration>struct Int : <Type usr="s:Ps17SignedIntegerType">SignedIntegerType</Type>{{.*}}{{.*}}<Type usr="s:Ps10Comparable">Comparable</Type>{{.*}}<Type usr="s:Ps9Equatable">Equatable</Type>{{.*}}</Declaration>

// RUN: %sourcekitd-test -req=module-groups -module Swift | FileCheck -check-prefix=GROUP1 %s
// GROUP1: <GROUPS>
// GROUP1-DAG: Lazy Views
// GROUP1-DAG: Assert
// GROUP1-DAG: String
// GROUP1-DAG: Collection
// GROUP1-DAG: Bool
// GROUP1-DAG: Math
// GROUP1-DAG: Misc
// GROUP1: <\GROUPS>

// RUN: %sourcekitd-test -req=interface-gen -module Swift -group-name Bool > %t.Bool.response
// RUN: FileCheck -check-prefix=CHECK-BOOL -input-file %t.Bool.response %s
// CHECK-BOOL-DAG: extension Bool : BooleanType {
// CHECK-BOOL-DAG: extension Bool : BooleanLiteralConvertible {

// These are not in the bool group:
// CHECK-BOOL-NOT: public struct Zip2Generator<Generator1 : GeneratorType, Generator2 : GeneratorType> : GeneratorType {
// CHECK-BOOL-NOT: public struct Zip2Sequence<Sequence1 : SequenceType, Sequence2 : SequenceType> : SequenceType {
// CHECK-BOOL-NOT: struct Int : SignedIntegerType, Comparable, Equatable {
// CHECK-BOOL-NOT: extension String.UTF16View.Index {
