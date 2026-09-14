#include "rclassicFixedSharedState.h"
#include "amiga/renderer_asm.h"

namespace TFE_Jedi
{
	RClassicFixedState s_rcfState = { 0 };
}  // TFE_Jedi

extern "C" {
	void* g_rcfState_ptr = &TFE_Jedi::s_rcfState;
}
