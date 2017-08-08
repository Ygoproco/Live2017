--ブート・スタッガード
--Boot Stagguard
--Scripted by Eerie Code
function c100332100.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100332100,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,100332100)
	e1:SetCondition(c100332100.spcon)
	e1:SetTarget(c100332100.sptg)
	e1:SetOperation(c100332100.spop)
	c:RegisterEffect(e1)
	--token
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100332100,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c100332100.tkcon)
	e2:SetTarget(c100332100.tktg)
	e2:SetOperation(c100332100.tkop)
	c:RegisterEffect(e2)
end
function c100332100.spcfilter(c,tp)
	return c:IsControler(tp) and c:IsRace(RACE_CYBERS)
end
function c100332100.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c100332100.spcfilter,1,nil,tp)
end
function c100332100.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c100332100.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c100332100.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function c100332100.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,100332100+100,0,0x4011,0,0,1,RACE_CYBERS,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function c100332100.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.IsPlayerCanSpecialSummonMonster(tp,100332100+100,0,0x4011,0,0,1,RACE_CYBERS,ATTRIBUTE_EARTH) then
		local token=Duel.CreateToken(tp,100332100+100)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end