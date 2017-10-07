--沼地のドロゴン
--Mudragon of the Swamp
--Script by nekrozar
function c100230008.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	--fusion material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_FUSION_MATERIAL)
	e0:SetCondition(c100230008.fscon)
	e0:SetOperation(c100230008.fsop)
	c:RegisterEffect(e0)
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c100230008.tglimit)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--att change
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100230008,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c100230008.atttg)
	e3:SetOperation(c100230008.attop)
	c:RegisterEffect(e3)
end
function c100230008.filter(c,fc)
	return not c:IsHasEffect(6205579) and c:IsCanBeFusionMaterial(fc)
end
function c100230008.spfilter(c,mg)
	return mg:IsExists(c100230008.spfilter2,1,c,c)
end
function c100230008.spfilter2(c,mc)
	return c:IsFusionAttribute(mc:GetAttribute()) and not c:IsRace(mc:GetRace())
end
function c100230008.fscon(e,g,gc)
	if g==nil then return true end
	local mg=g:Filter(c100230008.filter,gc,e:GetHandler())
	if gc then return c100230008.filter(gc,e:GetHandler()) and c100230008.spfilter(gc,mg) end
	return mg:IsExists(c100230008.spfilter,1,nil,mg)
end
function c100230008.fsop(e,tp,eg,ep,ev,re,r,rp,gc)
	local mg=eg:Filter(c100230008.filter,gc,e:GetHandler())
	local g1=nil
	local mc=gc
	if not gc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		g1=mg:FilterSelect(tp,c100230008.spfilter,1,1,nil,mg)
		mc=g1:GetFirst()
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g2=mg:FilterSelect(tp,c100230008.spfilter2,1,1,mc,mc)
	if g1 then g2:Merge(g1) end
	Duel.SetFusionMaterial(g2)
end
function c100230008.tglimit(e,c)
	return c:IsAttribute(e:GetHandler():GetAttribute())
end
function c100230008.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,563)
	local aat=Duel.AnnounceAttribute(tp,1,0xff-e:GetHandler():GetAttribute())
	e:SetLabel(aat)
end
function c100230008.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
