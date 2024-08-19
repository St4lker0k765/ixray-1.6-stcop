#pragma once

class CBlender_combine_volumetric : public IBlender  
{
public:
	virtual		LPCSTR		getComment()	{ return "INTERNAL: volumetric upsampling";	}
	virtual		BOOL		canBeDetailed()	{ return FALSE;	}
	virtual		BOOL		canBeLMAPped()	{ return FALSE;	}

	virtual		void		Compile			(CBlender_Compile& C);

	CBlender_combine_volumetric();
	virtual ~CBlender_combine_volumetric();
};
