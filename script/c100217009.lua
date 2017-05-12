--超重武者オタス－Ｋ
--Superheavy Samurai Helper
--Scripted by Eerie Code
function c100217009.initial_effect(c)
	--def up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100217009,0))
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c100217009.defcon)
	e1:SetCost(c100217009.defcost)
	e1:SetTarget(c100217009.deftg)
	e1:SetOperation(c100217009.defop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100217009,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c100217009.spcon)
	e2:SetCost(c100217009.spcost)
	e2:SetTarget(c100217009.sptg)
	e2:SetOperation(c100217009.spop)
	c:RegisterEffect(e2)
end
function c100217009.defcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL+TYPE_TRAP)==0
end
function c100217009.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function c100217009.deffilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a) and aux.nzdef(c)
end
function c100217009.deftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local a=Duel.GetAttacker()
	local d=a:GetAttackTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) 
		and c100217009.deffilter(chkc) and chkc~=e:GetLabelObject() end
	if chk==0 then return a:IsDefensePos() and d and d:IsControler(1-tp)
		and Duel.IsExistingTarget(c100217009.deffilter,tp,LOCATION_MZONE,0,1,a) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c100217009.deffilter,tp,LOCATION_MZONE,0,1,1,a)
	e:SetLabelObject(a)
end
function c100217009.defop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ac=e:GetLabelObject()
	if ac:IsRelateToBattle() and ac:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(tc:GetDefense())
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		ac:RegisterEffect(e1)
	end
end
function c100217009.spcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at:GetControler()~=tp and Duel.GetAttackTarget()==nil
end
function c100217009.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c100217009.spfilter(c,e,tp)
	return c:IsSetCard(0x9a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c100217009.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) 
		and c100217009.spfilter(chkc,e,tp) and chkc~=c end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c100217009.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c100217009.spfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c100217009.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then 
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end