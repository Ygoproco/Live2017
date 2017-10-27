--穿孔虫
function c88733579.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88733579,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c88733579.condition)
	e1:SetTarget(c88733579.target)
	e1:SetOperation(c88733579.operation)
	c:RegisterEffect(e1)
end
function c88733579.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
function c88733579.filter(c)
	return c:IsCode(27911549) --and c:GetPosition()~=POS_FACEUP_DEFENSE
end
function c88733579.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c88733579.filter,tp,LOCATION_DECK,0,1,nil) end
end
function c88733579.operation(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetMatchingGroup(c88733579.filter,tp,LOCATION_DECK,0,nil)
	if tg:GetCount()>0 then
		tc=tg:Select(tp,1,1,nil,1):GetFirst()
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
	end
end
