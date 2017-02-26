--マジック・スライム
function c3918345.initial_effect(c)
	aux.EnableDualAttribute(c)
	--reflect battle dam
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c3918345.damcon)
	e1:SetOperation(c3918345.damop)
	c:RegisterEffect(e1)
end
function c3918345.damcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return ep==tp and c:IsRelateToBattle() and eg:GetFirst()==c:GetBattleTarget() and aux.IsDualState(e)
end
function c3918345.damop(e,tp,eg,ep,ev,re,r,rp)
    local dam=Duel.GetBattleDamage(tp)
    Duel.ChangeBattleDamage(1-tp,dam,false)
    Duel.ChangeBattleDamage(tp,0)
end
