
#ifndef tiny_rtti_h
#define tiny_rtti_h

#include "../tiny.defines.h"
#include "../tiny.types.h"


/*
    RttiTypeRules struct
    General set of rules for interacting with a type
*/
typedef PACKED_STRUCT
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


/*
    RttiTypeData struct
    Basic structure for storing additional type information
*/
#define rtti_type_data_fields \
    union \
    { \
        uint32_t marker; \
        PACKED_STRUCT {uint8_t marker_bytes[3]; uint8_t base_type;}; \
    }; \
    void* context; \
    ShortString* name;
typedef PACKED_STRUCT
{
    rtti_type_data_fields;
}
RttiTypeData;


/*
    RttiMetaType struct
    Universal structure that describes meta types - types whose rules of behavior are determined by content
*/
#define RTTI_TYPEDATA_MASK 0x00ffffff
#define RTTI_TYPEDATA_MARKER ('R' + ('M' << 8) + ('T' << 16))
typedef REGISTER_DECL void (*RttiMetaTypeFunc)(/*RttiMetaType*/void* meta_type, void* value);
typedef REGISTER_DECL void (*RttiMetaTypeCopyFunc)(/*RttiMetaType*/void* meta_type, void* target, void* source);
typedef PACKED_STRUCT /*: RttiTypeData*/
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


/*
    RttiExType struct
    Universal structure describing any type, including pointer depth and additional information
*/
#define rtti_extype_fields \
    union \
    { \
        PACKED_STRUCT \
        { \
            uint8_t base_type; \
            uint8_t pointer_depth; \
            union \
            { \
                uint16_t id; \
                uint16_t code_page; \
                PACKED_STRUCT {uint8_t max_length; uint16_t flags;}; \
                uint16_t ex_flags; \
            }; \
        }; \
        PACKED_STRUCT \
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
typedef PACKED_STRUCT
{
    rtti_extype_fields;
}
RttiExType;


/*
    RttiValue (TValue) struct
    Any type value container (lightweight Variant)
*/
typedef PACKED_STRUCT
{
    RttiExType extype;
    ptr_t managed_data;
    uint8_t buffer[16];
}
RttiValue;


/*
    RttiArgument struct
    Signature argument description
*/
typedef PACKED_STRUCT
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


/*
    Initializing, finalizing and copying routine
*/
typedef REGISTER_DECL void (*RttiTypeFunc)(RttiExType* type, void* value);
typedef REGISTER_DECL void (*RttiCopyFunc)(RttiExType* type, void* target, void* source);


/*
    RttiOptions struct
    Library initialization options
*/
uint8_t RTTI_TYPE_GROUPS[256];
RttiTypeRules* RTTI_TYPE_RULES[256];
RttiTypeFunc RTTI_INIT_FUNCS[256];
RttiTypeFunc RTTI_FINAL_FUNCS[256];
RttiCopyFunc RTTI_COPY_FUNCS[256];
#define RTTI_INITNONE_FUNC 0
#define RTTI_INITPOINTER_FUNC 1
#define RTTI_INITPOINTERPAIR_FUNC 2
#define RTTI_INITMETATYPE_FUNC 3
#define RTTI_INITVALUE_FUNC 4
#define RTTI_INITBYTES_LOWFUNC 5
#define RTTI_INITBYTES_MAXCOUNT 32
#define RTTI_INITBYTES_HIGHFUNC RTTI_INITBYTES_LOWFUNC + RTTI_INITBYTES_MAXCOUNT
#define RTTI_INITRTL_LOWFUNC 38
#define RTTI_INITFULLSTATICARRAY_FUNC RTTI_INITRTL_LOWFUNC + 0
#define RTTI_INITFULLSTRUCTURE_FUNC RTTI_INITRTL_LOWFUNC + 1
#define RTTI_FINALNONE_FUNC 0
#define RTTI_FINALMETATYPE_FUNC 1
#define RTTI_FINALWEAKMETATYPE_FUNC 2
#define RTTI_FINALINTERFACE_FUNC 3
#define RTTI_FINALVALUE_FUNC 4
#define RTTI_FINALRTL_LOWFUNC 5
#define RTTI_FINALSTRING_FUNC RTTI_FINALRTL_LOWFUNC + 0
#define RTTI_FINALWIDESTRING_FUNC RTTI_FINALRTL_LOWFUNC + 1
#define RTTI_FINALWEAKINTERFACE_FUNC RTTI_FINALRTL_LOWFUNC + 2
#define RTTI_FINALREFOBJECT_FUNC RTTI_FINALRTL_LOWFUNC + 3
#define RTTI_FINALWEAKREFOBJECT_FUNC RTTI_FINALRTL_LOWFUNC + 4
#define RTTI_FINALVARIANT_FUNC RTTI_FINALRTL_LOWFUNC + 5
#define RTTI_FINALWEAKMETHOD_FUNC RTTI_FINALRTL_LOWFUNC + 6
#define RTTI_FINALDYNARRAY_FUNC RTTI_FINALRTL_LOWFUNC + 7
#define RTTI_FINALFULLDYNARRAY_FUNC RTTI_FINALRTL_LOWFUNC + 8
#define RTTI_FINALFULLSTATICARRAY_FUNC RTTI_FINALRTL_LOWFUNC + 9
#define RTTI_FINALFULLSTRUCTURE_FUNC RTTI_FINALRTL_LOWFUNC + 10
#define RTTI_COPYREFERENCE_FUNC 0
#define RTTI_COPYNATIVE_FUNC 1
#define RTTI_COPYALTERNATIVE_FUNC 2
#define RTTI_COPYMETATYPE_FUNC 3
#define RTTI_COPYWEAKMETATYPE_FUNC 4
#define RTTI_COPYMETATYPEBYTES_FUNC 5
#define RTTI_COPYINTERFACE_FUNC 6
#define RTTI_COPYVALUE_FUNC 7
#if defined (SMALLINT)
  #define RTTI_COPYBYTES_CARDINAL RTTI_COPYNATIVE_FUNC
  #define RTTI_COPYBYTES_INT64 RTTI_COPYNATIVE_FUNC + 1
#else
  #define RTTI_COPYBYTES_CARDINAL RTTI_COPYNATIVE_FUNC + 1
  #define RTTI_COPYBYTES_INT64 RTTI_COPYNATIVE_FUNC
#endif
#define RTTI_COPYBYTES_LOWFUNC 8
#define RTTI_COPYBYTES_MAXCOUNT 64
#define RTTI_COPYBYTES_HIGHFUNC RTTI_COPYBYTES_LOWFUNC + RTTI_COPYBYTES_MAXCOUNT
#define RTTI_COPYHFAREAD_LOWFUNC 73
#define RTTI_COPYHFAWRITE_LOWFUNC 76
#define RTTI_COPYSHORTSTRING_FUNC 79
#define RTTI_COPYRTL_LOWFUNC 80
#define RTTI_COPYSTRING_FUNC RTTI_COPYRTL_LOWFUNC + 0
#define RTTI_COPYWIDESTRING_FUNC RTTI_COPYRTL_LOWFUNC + 1
#define RTTI_COPYWEAKINTERFACE_FUNC RTTI_COPYRTL_LOWFUNC + 2
#define RTTI_COPYREFOBJECT_FUNC RTTI_COPYRTL_LOWFUNC + 3
#define RTTI_COPYWEAKREFOBJECT_FUNC RTTI_COPYRTL_LOWFUNC + 4
#define RTTI_COPYVARIANT_FUNC RTTI_COPYRTL_LOWFUNC + 5
#define RTTI_COPYWEAKMETHOD_FUNC RTTI_COPYRTL_LOWFUNC + 6
#define RTTI_COPYDYNARRAY_FUNC RTTI_COPYRTL_LOWFUNC + 7
#define RTTI_COPYFULLDYNARRAY_FUNC RTTI_COPYRTL_LOWFUNC + 8
#define RTTI_COPYSTATICARRAY_FUNC RTTI_COPYRTL_LOWFUNC + 9
#define RTTI_COPYFULLSTATICARRAY_FUNC RTTI_COPYRTL_LOWFUNC + 10
#define RTTI_COPYSTRUCTURE_FUNC RTTI_COPYRTL_LOWFUNC + 11
#define RTTI_COPYFULLSTRUCTURE_FUNC RTTI_COPYRTL_LOWFUNC + 12
#define RTTI_COPYVAROPENSTRINGWRITE_FUNC RTTI_COPYRTL_LOWFUNC + 13
#define RTTI_COPYARGARRAYREAD_FUNC RTTI_COPYRTL_LOWFUNC + 14
#define RTTI_COPYARGARRAYWRITE_FUNC RTTI_COPYRTL_LOWFUNC + 15
REGISTER_DECL RttiTypeRules* (*RttiCalculatedRules)(RttiExType* type, RttiTypeRules* buffer);


/*
    Initialization
*/
void init_library();

#endif
