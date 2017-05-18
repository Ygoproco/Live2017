--オッドアイズ・ランサー・ドラゴン
--Odd-Eyes Lancer Dragon
--Scripted by Eerie Code
function c83347294.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83347294,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c83347294.spcon)
	e1:SetCost(c83347294.spcost)
	e1:SetTarget(c83347294.sptg)
	e1:SetOperation(c83347294.spop)
	c:RegisterEffect(e1)
	--actlimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c83347294.aclimit)
	e2:SetCondition(c83347294.actcon)
	c:RegisterEffect(e2)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c83347294.reptg)
	e3:SetValue(c83347294.repval)
	e3:SetOperation(c83347294.repop)
	c:RegisterEffect(e3)
end
function c83347294.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsType(TYPE_PENDULUM)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp
end
function c83347294.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c83347294.cfilter,1,nil,tp)
end
function c83347294.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	local sg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	Duel.Release(sg,REASON_COST)
end
function c83347294.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c83347294.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c83347294.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function c83347294.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end
function c83347294.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(0x99)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)) and not c:IsReason(REASON_REPLACE)
end
function c83347294.desfilter(c,tp)
	local seq=c:GetSequence()
	return c:IsControler(tp) and c:IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE) and c:IsSetCard(0x99) and (not c:IsLocation(LOCATION_SZONE) or seq==6 or seq==7)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function c83347294.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c83347294.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(c83347294.desfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE,0,1,nil,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(83347294,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,c83347294.desfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE,0,1,1,nil,tp)
		e:SetLabelObject(g:GetFirst())
		Duel.HintSelection(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
function c83347294.repval(e,c)
	return c83347294.repfilter(c,e:GetHandlerPlayer())
end
function c83347294.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
