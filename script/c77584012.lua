--擬似空間
function c77584012.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--copy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77584012,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c77584012.cost)
	e2:SetOperation(c77584012.operation)
	c:RegisterEffect(e2)
end
function c77584012.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToRemoveAsCost() and c:GetOriginalCode()~=code
end
function c77584012.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(77584012)==0
		and Duel.IsExistingMatchingCard(c77584012.filter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler():GetCode()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c77584012.filter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler():GetCode())
	local code=g:GetFirst():GetOriginalCode()
	e:SetLabel(code)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c77584012.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local code=e:GetLabel()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(code)
	c:RegisterEffect(e1)
	local cid=c:CopyEffect(code,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,1)
	e:GetHandler():RegisterFlagEffect(77584012,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77584012,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_FZONE)
	e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	e2:SetLabel(cid)
	e2:SetLabelObject(e1)
	e2:SetOperation(c77584012.rstop)
	c:RegisterEffect(e2)
end
function c77584012.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	local e1=e:GetLabelObject()
	e1:Reset()
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
