--影六武衆－リハン
--Shadow Six Samurai – Rihan
--Scripted by Eerie Code
--Fusion procedure by edo9300
function c100419006.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(c100419006.splimit)
	c:RegisterEffect(e0)
	--Fusion procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c100419006.fscon)
	e1:SetOperation(c100419006.fsop)
	c:RegisterEffect(e1)
	--special summon rule
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c100419006.sprcon)
	e2:SetOperation(c100419006.sprop)
	c:RegisterEffect(e2)
	--fusion limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--remove
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(100419006,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c100419006.rmcost)
	e4:SetTarget(c100419006.rmtg)
	e4:SetOperation(c100419006.rmop)
	c:RegisterEffect(e4)
	--destroy replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetTarget(c100419006.reptg)
	e5:SetValue(c100419006.repval)
	e5:SetOperation(c100419006.repop)
	c:RegisterEffect(e5)
end
function c100419006.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function c100419006.ffilter(c,fc)
    return c:IsFusionSetCard(0x3d) and not c:IsHasEffect(6205579) and c:IsCanBeFusionMaterial(fc)
end
function c100419006.fselect(c,mg,sg,tp,fc)
	if sg:IsExists(Card.IsFusionAttribute,1,nil,c:GetFusionAttribute()) then return false end
	sg:AddCard(c)
	local res=false
	if sg:GetCount()==3 then
		res=true
	else
		res=mg:IsExists(c100419006.fselect,1,sg,mg,sg,tp,fc)
	end
	sg:RemoveCard(c)
	return res
end
function c100419006.fscon(e,g,gc,chkf)
	if g==nil then return true end
	local c=e:GetHandler()
	local tp=c:GetControler()
	local mg=g:Filter(c100419006.ffilter,nil,c)
	local sg=Group.CreateGroup()
	if gc then return c100419006.ffilter(gc,c) and c100419006.fselect(gc,mg,sg,tp,c) end
	return mg:IsExists(c100419006.fselect,1,sg,mg,sg,tp,c)
end
function c100419006.fsop(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
	local c=e:GetHandler()
	local mg=eg:Filter(c100419006.ffilter,nil,c)
	local sg=Group.CreateGroup()
	if gc then sg:AddCard(gc) end
	repeat
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local g=mg:FilterSelect(tp,c100419006.fselect,1,1,sg,mg,sg,tp,c)
		sg:Merge(g)
	until sg:GetCount()==3
	Duel.SetFusionMaterial(sg)
end
function c100419006.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(c100419006.sprfilter1,tp,LOCATION_MZONE,0,1,nil,tp,c)
end
function c100419006.sprfilter1(c,tp,fc)
	return c:IsFusionSetCard(0x3d) and c:IsAbleToGraveAsCost() and c:IsCanBeFusionMaterial(fc)
		and Duel.IsExistingMatchingCard(c100419006.sprfilter2,tp,LOCATION_MZONE,0,1,c,tp,fc,c)
end
function c100419006.sprfilter2(c,tp,fc,mc)
	return c:IsFusionSetCard(0x3d) and c:IsAbleToGraveAsCost() and c:IsCanBeFusionMaterial(fc) and not c:IsFusionAttribute(mc:GetFusionAttribute())
		and Duel.IsExistingMatchingCard(c100419006.sprfilter3,tp,LOCATION_MZONE,0,1,c,tp,fc,mc,c)
end
function c100419006.sprfilter3(c,tp,fc,mc1,mc2)
	local g=Group.FromCards(c,mc1,mc2)
	return c:IsFusionSetCard(0x3d) and c:IsAbleToGraveAsCost() and c:IsCanBeFusionMaterial(fc) and not c:IsFusionAttribute(mc1:GetFusionAttribute()) and not c:IsFusionAttribute(mc2:GetFusionAttribute())
end
function c100419006.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,c100419006.sprfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectMatchingCard(tp,c100419006.sprfilter2,tp,LOCATION_MZONE,0,1,1,g1:GetFirst(),tp,c,g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g3=Duel.SelectMatchingCard(tp,c100419006.sprfilter3,tp,LOCATION_MZONE,0,1,1,g1:GetFirst(),tp,c,g1:GetFirst(),g2:GetFirst())
	g1:Merge(g2)
	g1:Merge(g3)
	Duel.SendtoGrave(g1,REASON_COST)
end
function c100419006.costfilter(c,tp)
	return c:IsSetCard(0x3d) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
function c100419006.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100419006.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c100419006.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c100419006.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c100419006.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
function c100419006.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x3d)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function c100419006.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c100419006.repfilter,1,nil,tp) end
	return Duel.SelectYesNo(tp,aux.Stringid(100419006,1))
end
function c100419006.repval(e,c)
	return c100419006.repfilter(c,e:GetHandlerPlayer())
end
function c100419006.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
