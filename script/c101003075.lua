--The Glorious Noble Knights
function c101003075.initial_effect(c)
--Activate
local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c101003075.cost)
	e1:SetCountLimit(1,101003075)
	e1:SetTarget(c101003075.target)
	e1:SetOperation(c101003075.activate)
	c:RegisterEffect(e1)
end
function c101003075.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107a)
end
function c101003075.cost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c101003075.cfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c101003075.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c101003075.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c101003075.tcfilter(tc,ec)
	return tc:IsFaceup() and ec:CheckEquipTarget(tc)
end
function c101003075.ecfilter(c)
	return c:IsType(TYPE_EQUIP) and Duel.IsExistingTarget(c101003075.tcfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
function c101003075.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		if not Duel.IsExistingTarget(c101003075.ecfilter,tp,LOCATION_DECK,0,1,nil) then return false end
		if e:GetHandler():IsLocation(LOCATION_HAND) then
			return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		else return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(101003075,0))
	local g=Duel.SelectTarget(tp,c101003075.ecfilter,tp,LOCATION_DECK,0,1,1,nil)
	local ec=g:GetFirst()
	e:SetLabelObject(ec)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(101003075,1))
	Duel.SelectTarget(tp,c101003075.tcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,ec:GetEquipTarget(),ec)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,ec,1,0,0)
end
function c101003075.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local ec=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	if ec:IsLocation(LOCATION_DECK) and ec:IsRelateToEffect(e) then 
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			Duel.Equip(tp,ec,tc)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetRange(LOCATION_SZONE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetOperation(c25067275.desop)
			e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			ec:RegisterEffect(e1)
		end
	end
end