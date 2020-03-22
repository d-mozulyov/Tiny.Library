
#ifndef tiny_rtti_h
#define tiny_rtti_h

#include "tiny.defines.h"

typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef signed short int16_t;
typedef unsigned short uint16_t;
typedef signed int int32_t;
typedef unsigned int uint32_t;
typedef signed long long int64_t;
typedef unsigned long long uint64_t;
#if defined (SMALLINT)
  typedef int32_t size_t;
  typedef uint32_t usize_t;
#else
  typedef int64_t size_t;
  typedef uint64_t usize_t;
#endif
typedef uint16_t char16_t;
typedef uint32_t char32_t;
typedef int32_t HRESULT;
typedef void* ptr_t;
#if defined (CPUX86) || defined (CPUARM32) || defined (WIN64)
  typedef int64_t out_general;
#else
  #pragma pack(push, 1)
  typedef struct {size_t low; size_t high;} out_general;
  #pragma pack(pop)
#endif
#pragma pack(push, 1)
typedef struct
{
  #if defined (CPUARM) || defined (POSIX64)
    double d0;
    double d1;
    #if defined (CPUARM)
    double d2;
    double d3;
    #endif
  #endif
}
hfa_struct;
#pragma pack(pop)
typedef REGISTER_DECL out_general (*GeneralFunc)();
typedef REGISTER_DECL out_general (*GeneralFunc1)(ptr_t p1);
typedef REGISTER_DECL out_general (*GeneralFunc2)(ptr_t p1, ptr_t p2);
typedef REGISTER_DECL out_general (*GeneralFunc3)(ptr_t p1, ptr_t p2, ptr_t p3);
typedef REGISTER_DECL out_general (*GeneralFunc4)(ptr_t p1, ptr_t p2, ptr_t p3, ptr_t p4);


/*
    ShortString struct
    Delphi type equivalent
*/
#pragma pack(push, 1)
typedef struct
{
    union
    {
        char chars[256];
        uint8_t length;
    };
}
ShortString;
#pragma pack(pop)


/*
    RttiTypeRules struct
    General set of rules for interacting with a type
*/
#pragma pack(push, 1)
typedef struct
{
    uint32_t size;
    uint8_t stack_size;
    uint8_t return_mode; // "Return" field
    uint8_t flags;
    uint8_t init_func;
    uint8_t final_func;
    uint8_t weak_final_func;
    uint8_t copy_func;
    uint8_t weak_copy_func;
}
RttiTypeRules;
#pragma pack(pop)


/*
    RttiTypeData struct
    Basic structure for storing additional type information
*/
#define rtti_type_data_fields \
    union \
    { \
        uint32_t marker; \
        struct {uint8_t marker_bytes[3]; uint8_t base_type;}; \
    }; \
    void* context; \
    ShortString* name;
#pragma pack(push, 1)
typedef struct
{
    rtti_type_data_fields;
}
RttiTypeData;
#pragma pack(pop)


/*
    RttiMetaType struct
    Universal structure that describes meta types - types whose rules of behavior are determined by content
*/
#define RTTI_TYPEDATA_MASK 0x00ffffff
#define RTTI_TYPEDATA_MARKER ('R' + ('M' << 8) + ('T' << 16))
typedef REGISTER_DECL void (*RttiMetaTypeFunc)(/*RttiMetaType*/void* meta_type, void* value);
typedef REGISTER_DECL void (*RttiMetaTypeCopyFunc)(/*RttiMetaType*/void* meta_type, void* target, void* source);
#pragma pack(push, 1)
typedef struct /*: RttiTypeData*/
{
    rtti_type_data_fields;
    RttiTypeRules rules;
    RttiMetaTypeFunc init_func;
    RttiMetaTypeFunc final_func;
    RttiMetaTypeFunc weak_final_func;
    RttiMetaTypeCopyFunc copy_func;
    RttiMetaTypeCopyFunc weak_copy_func;
}
RttiMetaType;
#pragma pack(pop)


/*
    RttiExType struct
    Universal structure describing any type, including pointer depth and additional information
*/
#define rtti_extype_fields \
    union \
    { \
        struct \
        { \
            uint8_t base_type; \
            uint8_t pointer_depth; \
            union \
            { \
                uint16_t id; \
                uint16_t code_page; \
                struct {uint8_t max_length; uint16_t flags;}; \
                uint16_t ex_flags; \
            }; \
        }; \
        struct \
        { \
            uint32_t options; \
            union \
            { \
                void* custom_data; \
                RttiTypeData* type_data; \
                RttiMetaType* meta_type; \
            }; \
        }; \
    };
#pragma pack(push, 1)
typedef struct
{
    rtti_extype_fields;
}
RttiExType;
#pragma pack(pop)


/*
    RttiValue (TValue) struct
    Any type value container (lightweight Variant)
*/
#pragma pack(push, 1)
typedef struct
{
    RttiExType extype;
    ptr_t managed_data;
    uint8_t buffer[16];
}
RttiValue;
#pragma pack(pop)


/*
    RttiArgument struct
    Signature argument description
*/
#pragma pack(push, 1)
typedef struct
{
    rtti_extype_fields;
    ShortString* name;
    int32_t offset;
    uint8_t qualifier;
    uint8_t getter_func;
    uint8_t setter_func;
    int8_t high_offset;
}
RttiArgument;
#pragma pack(pop)


/*
    Initializing, finalizing and copying routine
*/
typedef REGISTER_DECL void (*RttiTypeFunc)(RttiExType* type, void* value);
typedef REGISTER_DECL void (*RttiCopyFunc)(RttiExType* type, void* target, void* source);


/*
    RttiOptions struct
    Library initialization options
*/

#define ERRORCODE_ACCESSVIOLATION 0
#define ERRORCODE_STACKOVERFLOW 1
#define ERRORCODE_SAFECALLERROR 2
#define ERRORCODE_OUTOFMEMORY 3
#define ERRORCODE_RANGEERROR 4
#define ERRORCODE_INTOVERFLOW 5
#define ERRORCODE_INTFCASTERROR 6
#define ERRORCODE_INVALIDCAST 7
#define ERRORCODE_INVALIDPTR 8
#define ERRORCODE_INVALIDOP 9
#define ERRORCODE_VARINVALIDOP 10
typedef REGISTER_DECL void (*ErrorHandlerFunc)(uint32_t tiny_error_code, uint32_t extended_code, void* return_address);
#if defined (MSWINDOWS)
  typedef STDCALL ptr_t (*SysAllocStringLenFunc)(char16_t* chars, uint32_t length);
  typedef STDCALL int32_t (*SysReAllocStringLenFunc)(ptr_t* value, char16_t* chars, uint32_t length);
  typedef STDCALL void (*SysFreeStringFunc)(ptr_t value);
#endif
#if defined (DELPHI)
  typedef REGISTER_DECL ptr_t (*GetMemoryFunc)(size_t size);
  typedef REGISTER_DECL int32_t (*FreeMemoryFunc)(ptr_t p);
  typedef REGISTER_DECL ptr_t (*ReallocMemoryFunc)(ptr_t p, size_t size);
  typedef REGISTER_DECL ptr_t (*StructureInfoFunc)(ptr_t target, void* type_info);
  typedef REGISTER_DECL ptr_t (*StructureCopyFunc)(ptr_t target, ptr_t source, void* type_info);
  typedef REGISTER_DECL ptr_t (*ArrayInfoFunc)(ptr_t target, void* type_info, usize_t count);
  typedef REGISTER_DECL ptr_t (*ArrayCopyFunc)(ptr_t target, ptr_t source, void* type_info, usize_t count);
  typedef REGISTER_DECL void (*SimpleClearFunc)(ptr_t target);
  typedef REGISTER_DECL void (*SimpleCopyFunc)(ptr_t target, ptr_t source);
  typedef REGISTER_DECL RttiTypeRules* (*RttiGetRulesFunc)(RttiExType* type, RttiTypeRules* buffer);
#endif
#pragma pack(push, 1)
typedef struct
{
    usize_t mode;
    ErrorHandlerFunc error_handler;
    #if defined (MSWINDOWS)
    SysAllocStringLenFunc SysAllocStringLen;
    SysReAllocStringLenFunc SysReAllocStringLen;
    SysFreeStringFunc SysFreeString;
    #endif

    #if defined (DELPHI)
    GetMemoryFunc getmem;
    FreeMemoryFunc freemem;
    ReallocMemoryFunc reallocmem;
    StructureInfoFunc init_structure;
    StructureInfoFunc final_structure;
    StructureCopyFunc copy_structure;
    ArrayInfoFunc init_array;
    ArrayInfoFunc final_array;
    ArrayCopyFunc copy_array;
    size_t vmt_obj_addref;
    size_t vmt_obj_release;
    SimpleClearFunc variant_clear;
    SimpleCopyFunc variant_copy;
    SimpleClearFunc weakinterface_clear;
    SimpleCopyFunc weakinterface_copy;
    SimpleClearFunc weakrefobject_clear;
    SimpleCopyFunc weakrefobject_copy;
    SimpleClearFunc weakmethod_clear;
    SimpleCopyFunc weakmethod_copy;
    ptr_t dummy_interface;
    uint8_t* groups;
    RttiTypeRules** rules;
    RttiTypeFunc* init_funcs;
    RttiTypeFunc* final_funcs;
    RttiCopyFunc* copy_funcs;
    RttiGetRulesFunc get_calculated_rules;
    #else
    RttiTypeFunc final_interface;
    RttiCopyFunc copy_interface;
    #endif
}
RttiOptions;
#pragma pack(pop)

FORCEINLINE RttiOptions* get_rtti_options();

#if defined (DELPHI)
  #define RTTI_TYPE_GROUPS rtti_options.groups
  #define RTTI_TYPE_RULES rtti_options.rules
  #define RTTI_INIT_FUNCS rtti_options.init_funcs
  #define RTTI_FINAL_FUNCS rtti_options.final_funcs
  #define RTTI_COPY_FUNCS rtti_options.copy_funcs
#else
  // ToDo
#endif


/*
    Initialization
*/
REGISTER_DECL void init_library(RttiOptions* options);

#endif
