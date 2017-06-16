--バーバリアン・レイジ
function c42233477.initial_effect(c)
	aux.AddPersistentProcedure(c,0,c42233477.filter,CATEGORY_ATKCHANGE,EFFECT_FLAG_DAMAGE_STEP,TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP,c42233477.condition)
	--eff
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.PersistentTargetFilter)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e2:SetValue(LOCATION_HAND)
	c:RegisterEffect(e2)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c42233477.descon)
	e2:SetOperation(c42233477.desop)
	c:RegisterEffect(e2)
end
function c42233477.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function c42233477.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
function c42233477.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
function c42233477.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
