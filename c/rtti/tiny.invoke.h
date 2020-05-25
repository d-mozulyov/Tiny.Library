
#ifndef tiny_invoke_h
#define tiny_invoke_h

#include "../tiny.defines.h"
#include "../tiny.types.h"
#include "tiny.rtti.h"


/*
    RttiRegisters struct
    Contains a set of registers needed to execute a function and retrieve a result
*/
#if defined (CPUX86)
    typedef native_int RttiGeneralRegisters[3];
    typedef PACKED_STRUCT{} RttiExtendedRegisters/*none*/;
#elif defined (WIN64)
    typedef native_int RttiGeneralRegisters[4];
    typedef double RttiExtendedRegisters[4];
#elif defined (CPUX64)
    typedef native_int RttiGeneralRegisters[6];
    typedef double RttiExtendedRegisters[8];
#elif defined (CPUARM32)
    typedef native_int RttiGeneralRegisters[4];
    typedef double RttiExtendedRegisters[8];
    typedef float RttiHalfExtendedRegisters[16];
#else // CPUARM64
    typedef native_int RttiGeneralRegisters[8 + 1];
    typedef double RttiExtendedRegisters[8];
#endif
typedef PACKED_STRUCT
{
    union
    {
    #if defined (CPUX86)
        /* Windows32, Linux32, MacOS32 */
        PACKED_STRUCT
        {
            int32_t RegEAX;
            int32_t RegEDX;
            int32_t RegECX;
            union
            {
                PACKED_STRUCT {int32_t OutEAX; int32_t OutEDX;};
                out_general OutGeneral;
                int32_t OutInt32;
                int64_t OutInt64;
                float OutFloat;
                double OutDouble;
                long double OutLongDouble;
                HRESULT OutSafeCall;
                uint8_t OutBytes[16];
            };
        };
        PACKED_STRUCT
        {
            RttiGeneralRegisters Generals;
            /*RttiExtendedRegisters*/uint8_t Extendeds[3]/*none*/;
        };
    #elif defined (WIN64)
        /* Windows64 */
        PACKED_STRUCT
        {
            int64_t RegRCX;
            int64_t RegRDX;
            int64_t RegR8;
            int64_t RegR9;
            double RegXMM0;
            double RegXMM1;
            double RegXMM2;
            double RegXMM3;
            union
            {
                int64_t OutRAX;
                out_general OutGeneral;
                double OutXMM0;
                int32_t OutInt32;
                int64_t OutInt64;
                float OutFloat;
                double OutDouble;
                HRESULT OutSafeCall;
                uint8_t OutBytes[8];
            };
        };
        PACKED_STRUCT
        {
            RttiGeneralRegisters Generals;
            RttiExtendedRegisters Extendeds;
        };
    #elif defined (CPUX64)
        /* Linux64, MacOS64 */
        PACKED_STRUCT
        {
            int64_t RegRDI;
            int64_t RegRSI;
            int64_t RegRDX;
            int64_t RegRCX;
            int64_t RegR8;
            int64_t RegR9;
            double RegXMM0;
            double RegXMM1;
            double RegXMM2;
            double RegXMM3;
            double RegXMM4;
            double RegXMM5;
            double RegXMM6;
            double RegXMM7;
            union
            {
                PACKED_STRUCT {int64_t OutRAX; int64_t OutRDX;};
                out_general OutGeneral;
                PACKED_STRUCT {double OutXMM0; double OutXMM1;};
                hfa_struct OutHFA;
                int32_t OutInt32;
                int64_t OutInt64;
                float OutFloat;
                double OutDouble;
                long double OutLongDouble;
                HRESULT OutSafeCall;
                uint8_t OutBytes[16];
            };
        };
        PACKED_STRUCT
        {
            RttiGeneralRegisters Generals;
            RttiExtendedRegisters Extendeds;
        };
    #elif defined (CPUARM32)
        /* Android32, iOS32 */
        PACKED_STRUCT
        {
            int32_t RegR0;
            int32_t RegR1;
            int32_t RegR2;
            int32_t RegR3;
            union
            {
                PACKED_STRUCT
                {
                    double RegD0;
                    double RegD1;
                    double RegD2;
                    double RegD3;
                    double RegD4;
                    double RegD5;
                    double RegD6;
                    double RegD7;
                };
                PACKED_STRUCT
                {
                    float RegS0;
                    float RegS1;
                    float RegS2;
                    float RegS3;
                    float RegS4;
                    float RegS5;
                    float RegS6;
                    float RegS7;
                    float RegS8;
                    float RegS9;
                    float RegS10;
                    float RegS11;
                    float RegS12;
                    float RegS13;
                    float RegS14;
                    float RegS15;
                };
            };
            union
            {
                PACKED_STRUCT {int32_t OutR0; int32_t OutR1;};
                out_general OutGeneral;
                PACKED_STRUCT {double OutD0; double OutD1;};
                hfa_struct OutHFA;
                int32_t OutInt32;
                int64_t OutInt64;
                float OutFloat;
                double OutDouble;
                HRESULT OutSafeCall;
                uint8_t OutBytes[32];
            };
        };
        PACKED_STRUCT
        {
            RttiGeneralRegisters Generals;
            union
            {
                RttiExtendedRegisters Extendeds;
                RttiHalfExtendedRegisters HalfExtendeds;
            };
        };
    #else
        /* Android64, iOS64 */
        PACKED_STRUCT
        {
            int64_t RegX0;
            int64_t RegX1;
            int64_t RegX2;
            int64_t RegX3;
            int64_t RegX4;
            int64_t RegX5;
            int64_t RegX6;
            int64_t RegX7;
            int64_t RegX8/*Result address*/;
            union
            {
                PACKED_STRUCT
                {
                    double RegD0;
                    double RegD1;
                    double RegD2;
                    double RegD3;
                    double RegD4;
                    double RegD5;
                    double RegD6;
                    double RegD7;
                };
                PACKED_STRUCT
                {
                    float RegS0;
                    int32_t _0;
                    float RegS1;
                    int32_t _1;
                    float RegS2;
                    int32_t _2;
                    float RegS3;
                    int32_t _3;
                    float RegS4;
                    int32_t _4;
                    float RegS5;
                    int32_t _5;
                    float RegS6;
                    int32_t _6;
                    float RegS7;
                    int32_t _7;
                };
            };
            union
            {
                PACKED_STRUCT {int64_t OutX0; int64_t OutX1;};
                out_general OutGeneral;
                PACKED_STRUCT {double OutD0; double OutD1;};
                hfa_struct OutHFA;
                int32_t OutInt32;
                int64_t OutInt64;
                float OutFloat;
                double OutDouble;
                HRESULT OutSafeCall;
                uint8_t OutBytes[32];
            };
        };
        PACKED_STRUCT
        {
            native_int Generals[8 + 1];
            double Extendeds[8];
        };
    #endif
    };
}
RttiRegisters;


/*
    RttiInvokeDump struct
    Memory buffer involved in executing a function
*/
typedef PACKED_STRUCT
{
    union
    {
        PACKED_STRUCT
        {
            RttiRegisters registers;
            void* return_address;
            native_int stack[(16 / sizeof(native_int)) * 255 + 2];
        };
        PACKED_STRUCT
        {
            RttiGeneralRegisters Generals;
            RttiExtendedRegisters Extendeds;
            union
            {
                out_general OutGeneral;
                hfa_struct OutHFA;
                int32_t OutInt32;
                int64_t OutInt64;
                float OutFloat;
                double OutDouble;
                long double OutLongDouble;
                HRESULT OutSafeCall;
                #if defined (WIN64)
                uint8_t OutBytes[8];
                #elif defined (CPUARM)
                uint8_t OutBytes[32];
                #else
                uint8_t OutBytes[16];
                #endif
            };
        };
        uint8_t Bytes[sizeof(RttiRegisters) + sizeof(void*) + 16 * 255 + 2 * sizeof(native_int)];
    };
}
RttiInvokeDump;


/*
    RttiSignature struct
    Description of function parameters, result and call convention
*/
typedef PACKED_STRUCT
{
    uint8_t call_conv;
    PACKED_STRUCT
    {
        uint8_t return_strategy;
        uint16_t reserved;
        uint32_t stack_size;
        #if defined (CPUX86)
        uint32_t stack_popsize;
        #endif
        int32_t	this_offset;
        int32_t	outermost_flag_offset;
    } dump_options;

    // ToDo arguments
}
RttiSignature;


/*
    RttiVirtualMethod struct
    Virtual interface method description
*/
typedef PACKED_STRUCT
{
    char* name;
    native_int index;
    RttiSignature* signature;
    void* context;
}
RttiVirtualMethod;
typedef REGISTER_DECL void (*RttiVirtualMethodCallback)(void* this, RttiVirtualMethod* method, RttiInvokeDump* dump);
typedef PACKED_STRUCT
{
    void* intercept_func;
    RttiVirtualMethod method;
    RttiVirtualMethodCallback callback;
    void* callback_this;
}
RttiVirtualMethodData;


/*
    Invoke routine
    This functionality allows you to execute a native function, having its address, signature and memory dump (for arguments)
    To get the optimal invoke function, use get_invoke_func ()
*/
typedef REGISTER_DECL void (*InvokeFunc)(RttiSignature* signature, void* code_address, RttiInvokeDump* dump);


/*
    Detect optimal invoke implementation
*/
REGISTER_DECL InvokeFunc get_invoke_func(int32_t code/*RttiSignature* signature*/);

/*
    Detect optimal intercept implementation
*/
REGISTER_DECL void* get_intercept_func(int32_t code/*RttiSignature* signature*/);

#endif
