--神の威光
function c16308000.initial_effect(c)
	aux.AddPersistentProcedure(c,0,c16308000.filter,nil,nil,0x1c0,0x1c1,nil,nil,nil,c16308000.operation)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.PersistentTargetFilter)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
function c16308000.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b)
end
function c16308000.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCountLimit(1)
		e2:SetLabel(2)
		e2:SetLabelObject(tc)
		e2:SetCondition(c16308000.tgcon)
		e2:SetOperation(c16308000.tgop)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		c:RegisterEffect(e2)
	end
end
function c16308000.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c16308000.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct-1
	e:SetLabel(ct)
	if ct==0 and e:GetHandler():IsHasCardTarget(e:GetLabelObject()) then
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
