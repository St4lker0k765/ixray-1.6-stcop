#include "stdafx.h"
#include "chimera.h"
#include "chimera_state_manager.h"

#include "../control_animation_base.h"
#include "../control_direction_base.h"
#include "../control_movement_base.h"
#include "../control_path_builder_base.h"

#include "../states/monster_state_rest.h"
#include "../states/monster_state_attack.h"
#include "../states/monster_state_panic.h"
#include "../states/monster_state_eat.h"
#include "../states/monster_state_hear_int_sound.h"
#include "../states/monster_state_hear_danger_sound.h"
#include "../states/monster_state_hitted.h"
#include "chimera_state_threaten.h"
#include "../states/state_test_state.h"

#include "chimera_attack_state.h"

CStateManagerChimera::CStateManagerChimera(CChimera* obj) : inherited(obj)
{
	add_state(eStateRest, xr_new<CStateMonsterRest>(obj));
	add_state(eStatePanic, xr_new<CStateMonsterPanic>(obj));
	add_state(eStateAttack, xr_new<ChimeraAttackState>(obj));
	add_state(eStateEat, xr_new<CStateMonsterEat>(obj));
	add_state(eStateHearInterestingSound, xr_new<CStateMonsterHearInterestingSound>(obj));
	add_state(eStateHearDangerousSound, xr_new<CStateMonsterHearDangerousSound>(obj));
	// 	add_state(eStateHitted,					xr_new<CStateMonsterHitted>					(obj));
	// 	add_state(eStateThreaten,				xr_new<CStateChimeraThreaten>				(obj));
	// 	add_state(eStateCustom,					xr_new<CStateMonsterTestState>				(obj));
}


CStateManagerChimera::~CStateManagerChimera()
{
}

void CStateManagerChimera::execute()
{
	u32 state_id = u32(-1);

	const CEntityAlive* enemy	= object->EnemyMan.get_enemy	();

	if (enemy) {
		//if (check_state(eStateThreaten)) state_id = eStateThreaten;
		switch (object->EnemyMan.get_danger_type()) {
			case eStrong:	state_id = eStatePanic; break;
			case eWeak:		state_id = eStateAttack; break;
		}
// 	else if (object->HitMemory.is_hit()) {
// 		state_id = eStateHitted;
 	} else if (object->hear_dangerous_sound) {
 		state_id = eStateHearDangerousSound;
 	} else if (object->hear_interesting_sound) {
 		state_id = eStateHearInterestingSound;
	} else {
		if (can_eat())	state_id = eStateEat;
		else			state_id = eStateRest;
	}
	
	//state_id = eStateCustom;

	select_state(state_id); 

	// выполнить текущее состояние
	get_state_current()->execute();

	prev_substate = current_substate;
}

