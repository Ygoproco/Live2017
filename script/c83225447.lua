--ドーピング
function c83225447.initial_effect(c)
	aux.AddEquipProcedure(c)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	--register
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_EQUIP)
	e3:SetOperation(c83225447.regop)
	e3:SetRange(LOCATION_SZONE)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--atkdown
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetLabelObject(e2)
	e4:SetCondition(c83225447.atkcon)
	e4:SetOperation(c83225447.atkop)
	c:RegisterEffect(e4)
end
function c83225447.regop(e,tp,eg,ep,ev,re,r,rp)
	local pe=e:GetLabelObject()
	pe:SetValue(700)
end
function c83225447.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c83225447.atkop(e,tp,eg,ep,ev,re,r,rp)
	local pe=e:GetLabelObject()
	local atk=pe:GetValue()
	pe:SetValue(atk-200)
end
