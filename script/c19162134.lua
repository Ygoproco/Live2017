--エンタメデュエル
--Dueltainment
--Scripted by Eerie Code
function c19162134.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--draw on Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c19162134.spcon1)
	e2:SetOperation(c19162134.drop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCondition(c19162134.spcon2)
	e3:SetOperation(c19162134.drop2)
	c:RegisterEffect(e3)
	--draw on 5 battles
	local e4=e2:Clone()
	e4:SetCode(EVENT_BATTLED)
	e4:SetCondition(c19162134.btcon1)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_BATTLED)
	e5:SetCondition(c19162134.btcon2)
	c:RegisterEffect(e5)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_FZONE)
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	--draw on Chain Link
	local e6=e2:Clone()
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetCondition(c19162134.chcon1)
	c:RegisterEffect(e6)
	local e7=e3:Clone()
	e7:SetCode(EVENT_CHAIN_SOLVING)
	e7:SetCondition(c19162134.chcon2)
	c:RegisterEffect(e7)
	--draw on gamble
	if Duel.GetTossedCoinCount and Duel.GetTossedDiceCount then
		local e8=e2:Clone()
		e8:SetCode(EVENT_CHAIN_SOLVED)
		e8:SetCondition(c19162134.tosscon1)
		c:RegisterEffect(e8)
		local e9=e3:Clone()
		e9:SetCode(EVENT_CHAIN_SOLVED)
		e9:SetCondition(c19162134.tosscon2)
		c:RegisterEffect(e9)
	else
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_CUSTOM+19162134)
		e8:SetRange(LOCATION_FZONE)
		e8:SetCountLimit(1)
		e8:SetCondition(c19162134.gmcon1)
		e8:SetOperation(c19162134.drop1)
		c:RegisterEffect(e8)
		local e9=e8:Clone()
		e9:SetCondition(c19162134.gmcon2)
		e9:SetOperation(c19162134.drop2)
		c:RegisterEffect(e9)
	end
	--draw on damage
	local ea=e2:Clone()
	ea:SetCode(EVENT_DAMAGE)
	ea:SetCondition(c19162134.damcon1)
	c:RegisterEffect(ea)
	local eb=e3:Clone()
	eb:SetCode(EVENT_DAMAGE)
	eb:SetCondition(c19162134.damcon2)
	c:RegisterEffect(eb)
	--gamble counters (to be removed after core update)
	if Duel.GetTossedCoinCount and Duel.GetTossedDiceCount and not c19162134.global_flag then
		c19162134.global_flag=true
		c19162134[0]=0
		c19162134[1]=0
		--Checks effects that make a player toss a coin or throw a dice
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(c19162134.checkop)
		Duel.RegisterEffect(ge1,0)
		--Checks effects that allow a player to redo a coin toss or dice roll
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CUSTOM+19162135)
		ge2:SetOperation(c19162134.checkop2)
		Duel.RegisterEffect(ge2,0)
		--Reset at the start of the next Draw Phase
		local ge0=Effect.CreateEffect(c)
		ge0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge0:SetOperation(c19162134.clear)
		Duel.RegisterEffect(ge0,0)
	end
end
function c19162134.spfilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function c19162134.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==5 and eg:IsExists(c19162134.spfilter,1,nil,tp) and eg:GetClassCount(Card.GetLevel)==5
end
function c19162134.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==5 and eg:IsExists(c19162134.spfilter,1,nil,1-tp) and eg:GetClassCount(Card.GetLevel)==5
end
function c19162134.drop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,19162134)
	Duel.Draw(tp,2,REASON_EFFECT)
end
function c19162134.drop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,19162134)
	Duel.Draw(1-tp,2,REASON_EFFECT)
end
function c19162134.btcon1(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	if a then
		a:RegisterFlagEffect(19162134,RESET_EVENT+0x1fe0000,0,1)
		return a:GetFlagEffect(19162134)==5
	else return false end
end
function c19162134.btcon2(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a:IsControler(tp) then a,d=d,a end
	if a then
		a:RegisterFlagEffect(19162134,RESET_EVENT+0x1fe0000,0,1)
		return a:GetFlagEffect(19162134)==5
	else return false end
end
function c19162134.chcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and Duel.GetCurrentChain()>=5 and e:GetHandler():GetFlagEffect(1)>0
end
function c19162134.chcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.GetCurrentChain()>=5 and e:GetHandler():GetFlagEffect(1)>0
end
function c19162134.tosscon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTossedCoinCount(tp)+Duel.GetTossedDiceCount(tp)>=5 and e:GetHandler():GetFlagEffect(1)>0
end
function c19162134.tosscon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTossedCoinCount(1-tp)+Duel.GetTossedDiceCount(1-tp)>=5 and e:GetHandler():GetFlagEffect(1)>0
end
function c19162134.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.GetLP(tp)<=500
end
function c19162134.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.GetLP(1-tp)<=500
end
--To be removed after core update
function c19162134.gmcon1(e,tp,eg,ep,ev,re,r,rp)
	return c19162134[tp]==5
end
function c19162134.gmcon2(e,tp,eg,ep,ev,re,r,rp)
	return c19162134[1-tp]==5
end
function c19162134.checkop(e,tp,eg,ep,ev,re,r,rp)
	local ex1,g1,gc1,dp1,dv1=Duel.GetOperationInfo(0,CATEGORY_DICE)
	local ex2,g2,gc2,dp2,dv2=Duel.GetOperationInfo(0,CATEGORY_COIN)
	if ex1 then
		if dp1==PLAYER_ALL then
			c19162134[0]=c19162134[0]+dv1
			c19162134[1]=c19162134[1]+dv1
		else
			c19162134[dp1]=c19162134[dp1]+dv1
		end
	end
	if ex2 then
		if dp2==PLAYER_ALL then
			c19162134[0]=c19162134[0]+dv2
			c19162134[1]=c19162134[1]+dv2
		else
			c19162134[dp2]=c19162134[dp2]+dv2
		end
	end
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+19162134,re,r,rp,0,0)
end
function c19162134.checkop2(e,tp,eg,ep,ev,re,r,rp)
	if ep==PLAYER_ALL then
		c19162134[0]=c19162134[0]+ev
		c19162134[1]=c19162134[1]+ev
	else
		c19162134[ep]=c19162134[ep]+ev
	end
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+19162134,re,r,rp,0,0)
end
function c19162134.clear(e,tp,eg,ep,ev,re,r,rp)
	c19162134[0]=0
	c19162134[1]=0
end