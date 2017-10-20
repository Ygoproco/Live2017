--心眼の祭殿
function c92481084.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(c92481084.dop)
	c:RegisterEffect(e2)
end
function c92481084.dop(e,tp,eg,ep,ev,re,r,rp)
	local te=Duel.IsPlayerAffectedByEffect(ep,EFFECT_REVERSE_DAMAGE)
	if te then
		local val=te:GetValue()
		if type(val)=='function' then
			if val(e,re,r,rp,rc) then return end
		else return end
	end
	Duel.ChangeBattleDamage(ep,1000)
end
