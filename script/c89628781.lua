--忍法 空蝉の術
function c89628781.initial_effect(c)
	aux.AddPersistentProcedure(c,0,c89628781.filter)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.PersistentTargetFilter)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
function c89628781.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2b)
end
