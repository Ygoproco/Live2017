--E・HERO ゴッド・ネオス
function c31111109.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(c31111109.fuscon)
	e1:SetOperation(c31111109.fusop)
	c:RegisterEffect(e1)
	--copy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31111109,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c31111109.copytg)
	e2:SetOperation(c31111109.copyop)
	c:RegisterEffect(e2)
	--spsummon condition
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(aux.fuslimit)
	c:RegisterEffect(e3)
end
c31111109.material_setcode=0x8
function c31111109.ffilter1(c)
	return (c:IsFusionSetCard(0x9) or c:IsHasEffect(511002961)) and not c:IsHasEffect(6205579)
end
function c31111109.ffilter2(c)
	return (c:IsFusionSetCard(0x1f) or c:IsHasEffect(511002961)) and not c:IsHasEffect(6205579)
end
function c31111109.ffilter3(c)
	return (c:IsFusionSetCard(0x8) or c:IsHasEffect(511002961)) and not c:IsHasEffect(6205579)
end
function c31111109.filterchk1(c,mg,g2,ct,chkf,tp,gc)
	local tg
	if g2==nil or g2:GetCount()==0 then tg=Group.CreateGroup() else tg=g2:Clone() end
	local g=mg:Clone()
	tg:AddCard(c)
	g:RemoveCard(c)
	local ctc=ct+1
	if ctc==3 and (not tg:IsExists(c31111109.ffilter1,1,nil) or not tg:IsExists(c31111109.ffilter2,1,nil) or not tg:IsExists(c31111109.ffilter3,1,nil)) then 
		return false end
	if ctc==4 and gc and not tg:IsContains(gc) then return false end
	if ctc==5 then
		return not tg:IsExists(aux.TuneMagFusFilter,1,nil,tg,tp) and (chkf==PLAYER_NONE or tg:IsExists(aux.FConditionCheckF,1,nil,chkf))
	else
		return g:IsExists(c31111109.filterchk1,1,nil,g,tg,ctc,chkf,tp,gc)
	end
end
function c31111109.fuscon(e,g,gc,chkf)
	if g==nil then return false end
	local mg=g:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
	local g1=mg:Filter(c31111109.ffilter1,nil)
	local g2=mg:Filter(c31111109.ffilter2,nil)
	local g3=mg:Filter(c31111109.ffilter3,nil)
	g1:Merge(g2)
	g1:Merge(g3)
	if gc and not gc:IsCanBeFusionMaterial(e:GetHandler()) then return false end
	if gc then g1:AddCard(gc) end
	return g1:IsExists(c31111109.filterchk1,1,nil,g1,nil,0,chkf,e:GetHandlerPlayer(),gc)
end
function c31111109.fusop(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
	local mg=eg:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
	local g=mg:Filter(c31111109.ffilter1,nil)
	local g2=mg:Filter(c31111109.ffilter2,nil)
	local g3=mg:Filter(c31111109.ffilter3,nil)
	g:Merge(g2)
	g:Merge(g3)
	if gc then g:AddCard(gc) end
	local p=tp
	local sfhchk=false
	if Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
		p=1-tp Duel.ConfirmCards(1-tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
	end
	local matg=Group.CreateGroup()
	for i=1,5 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local g1=g:FilterSelect(p,c31111109.filterchk1,1,1,nil,g,matg,i-1,chkf,tp,gc)
		g:Sub(g1)
		matg:Merge(g1)
	end
	if gc then g:RemoveCard(gc) end
	if sfhchk then Duel.ShuffleHand(tp) end
	Duel.SetFusionMaterial(matg)
end
function c31111109.filter(c)
	return (c:IsSetCard(0x9) or c:IsSetCard(0x1f) or c:IsSetCard(0x8)) and c:IsType(TYPE_MONSTER)
		and not c:IsForbidden() and c:IsAbleToRemove()
end
function c31111109.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31111109.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c31111109.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,c31111109.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c31111109.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) then
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=1 then	return end
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+0x1ff0000)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(31111109,1))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e2:SetLabel(cid)
		e2:SetOperation(c31111109.rstop)
		c:RegisterEffect(e2)
	end
end
function c31111109.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
