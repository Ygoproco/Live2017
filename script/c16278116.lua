--竜の束縛
function c16278116.initial_effect(c)
	aux.AddPersistentProcedure(c,0,c16278116.filter,nil,nil,nil,0x1c0)
	--cannot spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c16278116.splimit)
	c:RegisterEffect(e3)
	--Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c16278116.descon)
	e4:SetOperation(c16278116.desop)
	c:RegisterEffect(e4)
end
function c16278116.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttackBelow(2500) and c:IsDefenseBelow(2500)
end
function c16278116.splimit(e,c,tp,sumtp,sumpos)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and c:IsAttackBelow(tc:GetBaseAttack())
end
function c16278116.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
function c16278116.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
