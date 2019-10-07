# Tiny.Rtti

The project has the following conceptual features:
* Standard types, including FreePascal, old and new versions of Delphi, convenient functions for managing them.
* Universal data representation, regardless of programming language and compiler version.
* Convert standard RTTI to universal data representation.
* Minimizing dependencies on heavy units like Classes, Variants, Generics, etc.
* Cross-platform functions invoke, including FreePascal and old versions of Delphi, creation of function and interface interpreters.
* Marshalling (serialization and deserialization of data) through different formatters: JSON, XML, [FlexBin](FlexBin.RUS.md) and others.
* Easy to use unit testing library that does not access the memory manager.