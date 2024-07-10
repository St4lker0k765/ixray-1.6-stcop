#pragma once
#include "../state.h"


class CStateGroupAttackMoveToHomePoint : public CState {
protected:
	typedef CState	inherited;
	typedef CState*	state_ptr;

	u32					m_target_node;
	bool				m_skip_camp;

	TTime				m_first_tick_enemy_inaccessible;
	TTime				m_last_tick_enemy_inaccessible;
	TTime				m_state_started;

public:
						CStateGroupAttackMoveToHomePoint(CBaseMonster *obj);
	virtual	void		initialize				();
	virtual void 		finalize				();
	virtual void 		critical_finalize		();
	virtual void		remove_links			(CObject* object) { inherited::remove_links(object);}

	virtual bool		check_start_conditions	();
	virtual bool		check_completion		();

	virtual	void		reselect_state			();
	virtual	void		setup_substates			();

			bool		enemy_inaccessible		();
};

#include "group_state_home_point_attack_inline.h"
