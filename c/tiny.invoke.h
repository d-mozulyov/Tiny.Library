
#ifndef tiny_invoke_h
#define tiny_invoke_h

#include "tiny.defines.h"
#include "tiny.rtti.h"


/*
    RttiRegisters struct
    Contains a set of registers needed to execute a function and retrieve a result
*/
#pragma pack(push, 1)
#if defined (CPUX86)
    typedef size_t RttiGeneralRegisters[3];
    typedef struct{} RttiExtendedRegisters/*none*/;
#elif defined (WIN64)
    typedef size_t RttiGeneralRegisters[4];
    typedef double RttiExtendedRegisters[4];
#elif defined (CPUX64)
    typedef size_t RttiGeneralRegisters[6];
    typedef double RttiExtendedRegisters[8];
#elif defined (CPUARM32)
    typedef size_t RttiGeneralRegisters[4];
    typedef double RttiExtendedRegisters[8];
    typedef float RttiHalfExtendedRegisters[16];
#else // CPUARM64
    typedef size_t RttiGeneralRegisters[8 + 1];
    typedef double RttiExtendedRegisters[8];
#endif
typedef struct
{
    union
    {
    #if defined (CPUX86)
        /* Windows32, Linux32, MacOS32 */
        struct
        {
            int32_t RegEAX;
            int32_t RegEDX;
            int32_t RegECX;
            union
            {
                struct {int32_t OutEAX; int32_t OutEDX;};
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
        struct
        {
            RttiGeneralRegisters Generals;
            /*RttiExtendedRegisters*/uint8_t Extendeds[3]/*none*/;
        };
    #elif defined (WIN64)
        /* Windows64 */
        struct
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
        struct
        {
            RttiGeneralRegisters Generals;
            RttiExtendedRegisters Extendeds;
        };
    #elif defined (CPUX64)
        /* Linux64, MacOS64 */
        struct
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
                struct {int64_t OutRAX; int64_t OutRDX;};
                out_general OutGeneral;
                struct {double OutXMM0; double OutXMM1;};
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
        struct
        {
            RttiGeneralRegisters Generals;
            RttiExtendedRegisters Extendeds;
        };
    #elif defined (CPUARM32)
        /* Android32, iOS32 */
        struct
        {
            int32_t RegR0;
            int32_t RegR1;
            int32_t RegR2;
            int32_t RegR3;
            union
            {
                struct
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
                struct
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
                struct {int32_t OutR0; int32_t OutR1;};
                out_general OutGeneral;
                struct {double OutD0; double OutD1;};
                hfa_struct OutHFA;
                int32_t OutInt32;
                int64_t OutInt64;
                float OutFloat;
                double OutDouble;
                HRESULT OutSafeCall;
                uint8_t OutBytes[32];
            };
        };
        struct
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
        struct
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
                struct
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
                struct
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
                struct {int64_t OutX0; int64_t OutX1;};
                out_general OutGeneral;
                struct {double OutD0; double OutD1;};
                hfa_struct OutHFA;
                int32_t OutInt32;
                int64_t OutInt64;
                float OutFloat;
                double OutDouble;
                HRESULT OutSafeCall;
                uint8_t OutBytes[32];
            };
        };
        struct
        {
            size_t Generals[8 + 1];
            double Extendeds[8];
        };
    #endif
    };
}
RttiRegisters;
#pragma pack(pop)


/*
    RttiInvokeDump struct
    Memory buffer involved in executing a function
*/
#pragma pack(push, 1)
typedef struct
{
    union
    {
        struct
        {
            RttiRegisters registers;
            void* return_address;
            size_t stack[(16 / sizeof(size_t)) * 255 + 2];
        };
        struct
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
        uint8_t Bytes[sizeof(RttiRegisters) + sizeof(void*) + 16 * 255 + 2 * sizeof(size_t)];
    };
}
RttiInvokeDump;
#pragma pack(pop)


/*
    RttiSignature struct
    Description of function parameters, result and call convention
*/
#pragma pack(push, 1)
typedef struct
{
    uint8_t call_conv;
    struct {
        uint8_t return_strategy;
        uint16_t reserved;
        uint32_t stack_size;
        #if defined (CPUX86)
        uint32_t stack_popsize;
        #endif
        int32_t	this_offset;
        int32_t	constructor_flag_offset;
    } dump_options;

    // ToDo arguments
}
RttiSignature;
#pragma pack(pop)


/*
    RttiVirtualMethod struct
    Virtual interface method description
*/
#pragma pack(push, 1)
typedef struct
{
    char* name;
    size_t index;
    RttiSignature* signature;
    void* context;
}
RttiVirtualMethod;
typedef REGISTER_DECL void (*RttiVirtualMethodCallback)(void* this, RttiVirtualMethod* method, RttiInvokeDump* dump);
typedef struct
{
    void* intercept_func;
    RttiVirtualMethod method;
    RttiVirtualMethodCallback callback;
    void* callback_this;
}
RttiVirtualMethodData;
#pragma pack(pop)


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
