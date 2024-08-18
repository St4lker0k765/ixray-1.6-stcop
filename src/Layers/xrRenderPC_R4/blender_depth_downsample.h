#pragma once

class CBlender_depth_downsample : public IBlender  
{
public:
	virtual		LPCSTR		getComment()	{ return "INTERNAL: depth downsampling";	}
	virtual		BOOL		canBeDetailed()	{ return FALSE;	}
	virtual		BOOL		canBeLMAPped()	{ return FALSE;	}

	virtual		void		Compile			(CBlender_Compile& C);

	CBlender_depth_downsample();
	virtual ~CBlender_depth_downsample();
};
