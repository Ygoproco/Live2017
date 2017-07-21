--超越融合
function c76647978.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76647978,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c76647978.cost)
	e1:SetTarget(c76647978.target)
	e1:SetOperation(c76647978.activate)
	c:RegisterEffect(e1)
	if not UltraPolyTable then UltraPolyTable={} end
	if not c76647978.global_check then
		c76647978.global_check=true
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetOperation(c76647978.clear)
		Duel.RegisterEffect(ge2,0)
	end
end
function c76647978.clear(e,tp,eg,ep,ev,re,r,rp)
	for c,e2 in ipairs(UltraPolyTable) do
		local g=e2:GetLabelObject()
		g:Remove(aux.FilterEqualFunction(Card.GetFlagEffect,0,76647978),nil)
		if g:GetCount()<=0 then
			g:DeleteGroup()
			UltraPolyTable[c]=nil
		end
	end
end
function c76647978.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end
function c76647978.filter1(c,e,tp,mg,f,chkf)
	return mg:IsExists(c76647978.filter2,1,c,e,tp,c,f,chkf)
end
function c76647978.filter2(c,e,tp,mc,f,chkf)
	local mg=Group.FromCards(c,mc)
	return Duel.IsExistingMatchingCard(c76647978.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,f,chkf)
end
function c76647978.ffilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c76647978.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and PLAYER_NONE or tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		local res=mg1:IsExists(c76647978.filter1,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=mg2:IsExists(c76647978.filter1,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function c76647978.filter0(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
function c76647978.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and PLAYER_NONE or tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(c76647978.filter0,nil,e)
	local g1=mg1:Filter(c76647978.filter1,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local g2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		g2=mg2:Filter(c76647978.filter1,nil,e,tp,mg2,mf,chkf)
	end
	local tc=nil
	if g2~=nil and g2:GetCount()>0 and (g1:GetCount()==0 or Duel.SelectYesNo(tp,ce:GetDescription())) then
		local mf=ce:GetValue()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local sg1=mg2:FilterSelect(tp,c76647978.filter1,1,1,nil,e,tp,mg2,mf,chkf)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local sg2=mg2:FilterSelect(tp,c76647978.filter2,1,1,sg1:GetFirst(),e,tp,sg1:GetFirst(),mf,chkf)
		sg1:Merge(sg2)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,c76647978.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,sg1,mf,chkf)
		tc=sg:GetFirst()
		local fop=ce:GetOperation()
		fop(ce,e,tp,tc,sg1)
	elseif g1:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local sg1=mg1:FilterSelect(tp,c76647978.filter1,1,1,nil,e,tp,mg1,nil,chkf)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local sg2=mg1:FilterSelect(tp,c76647978.filter2,1,1,sg1:GetFirst(),e,tp,sg1:GetFirst(),nil,chkf)
		sg1:Merge(sg2)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,c76647978.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,sg1,nil,chkf)
		tc=sg:GetFirst()
		tc:SetMaterial(sg1)
		Duel.SendtoGrave(sg1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	end
	if tc then
		local c=e:GetHandler()
		tc:RegisterFlagEffect(76647978,RESET_EVENT+0x1fe0000,0,1)
		tc:CompleteProcedure()
		local g
		if UltraPolyTable[c]==nil then
			g=Group.CreateGroup()
			g:KeepAlive()
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(76647978,1))
			e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e2:SetType(EFFECT_TYPE_IGNITION)
			e2:SetRange(LOCATION_GRAVE)
			e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
			e2:SetCost(c76647978.spcost)
			e2:SetTarget(c76647978.sptg)
			e2:SetOperation(c76647978.spop)
			e2:SetLabelObject(g)
			e2:SetReset(RESET_EVENT+RESET_TODECK)
			c:RegisterEffect(e2)
			UltraPolyTable[c]=e2
		else
			g=UltraPolyTable[c]:GetLabelObject()
		end
		g:AddCard(tc)
	end
end
function c76647978.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c76647978.mgfilter(c,e,tp,fusc,mg)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x40008)==0x40008 and c:GetReasonCard()==fusc
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and fusc:CheckFusionMaterial(mg,c)
end
function c76647978.spfilter(c,e,tp)
	local g=UltraPolyTable[e:GetHandler()]:GetLabelObject()
	if c:IsFaceup() and c:GetFlagEffect(76647978)~=0 and g and g:IsContains(c) then
		local mg=c:GetMaterial()
		local ct=mg:GetCount()
		return ct>0 and ct<=Duel.GetLocationCount(tp,LOCATION_MZONE)
			and mg:FilterCount(c76647978.mgfilter,nil,e,tp,c,mg)==ct
			and (not Duel.IsPlayerAffectedByEffect(tp,59822133) or ct<=1)
	else return false end
end
function c76647978.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c76647978.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c76647978.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c76647978.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function c76647978.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local mg=tc:GetMaterial()
	local ct=mg:GetCount()
	if ct>0 and ct<=Duel.GetLocationCount(tp,LOCATION_MZONE)
		and mg:FilterCount(c76647978.mgfilter,nil,e,tp,tc,mg)==ct
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		local sc=mg:GetFirst()
		while sc do
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+0x1fe0000)
				sc:RegisterEffect(e1,true)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+0x1fe0000)
				sc:RegisterEffect(e2,true)
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_SET_ATTACK_FINAL)
				e3:SetValue(0)
				e3:SetReset(RESET_EVENT+0x1fe0000)
				sc:RegisterEffect(e3,true)
				local e4=e3:Clone()
				e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
				sc:RegisterEffect(e4,true)
			end
			sc=mg:GetNext()
		end
		Duel.SpecialSummonComplete()
	end
end
