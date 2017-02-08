--Clash in the Subterror Caverns
--Scripted by Eerie Code
function c68001309.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c68001309.atktg)
	e2:SetValue(c68001309.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(68001309,0))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(c68001309.thcon)
	e4:SetTarget(c68001309.thtg)
	e4:SetOperation(c68001309.thop)
	c:RegisterEffect(e4)
end
function c68001309.atktg(e,c)
	return c:IsSetCard(0xed)
end
function c68001309.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)*500
end
function c68001309.thcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	local rc=eg:GetFirst()
	return rc:IsControler(tp) and rc:IsSetCard(0xed)
end
function c68001309.thfilter(c)
	return c:IsSetCard(0xed) and not c:IsCode(68001309) and c:IsAbleToHand()
end
function c68001309.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c68001309.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c68001309.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectTarget(tp,c68001309.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
function c68001309.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
