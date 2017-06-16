--闇の呪縛
function c29267084.initial_effect(c)
	aux.AddPersistentProcedure(c,1,aux.FilterBoolFunction(Card.IsFaceup),CATEGORY_POSITION,EFFECT_FLAG_DAMAGE_STEP,TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP,c29267084.condition)
	--eff
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.PersistentTargetFilter)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(-700)
	c:RegisterEffect(e3)
	--Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c29267084.descon)
	e4:SetOperation(c29267084.desop)
	c:RegisterEffect(e4)
end
function c29267084.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function c29267084.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
function c29267084.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(), REASON_EFFECT)
end
