--しびれ薬
function c50152549.initial_effect(c)
	aux.AddEquipProcedure(c,nil,c50152549.filter)
	--atklimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e2)
end
function c50152549.filter(c)
	return not c:IsRace(RACE_MACHINE)
end
