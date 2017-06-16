--罅割れゆく斧
function c12117532.initial_effect(c)
	aux.AddPersistentProcedure(c,nil,aux.FilterBoolFunction(Card.IsFaceup),CATEGORY_DISABLE,nil,nil,TIMING_END_PHASE,nil,nil,c12117532.target)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c12117532.descon)
	e2:SetOperation(c12117532.desop)
	c:RegisterEffect(e2)
	--atkdown
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c12117532.atkcon)
	e3:SetOperation(c12117532.atkop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(aux.PersistentTargetFilter)
	e4:SetValue(c12117532.val)
	c:RegisterEffect(e4)
end
function c12117532.target(e,tp,eg,ep,ev,re,r,rp,tc)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
end
function c12117532.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
function c12117532.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function c12117532.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFirstCardTarget()~=nil
end
function c12117532.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc then
		tc:RegisterFlagEffect(12117532,RESET_EVENT+0x1fe0000,0,0)
	end
end
function c12117532.val(e,c)
	return c:GetFlagEffect(12117532)*-500
end
