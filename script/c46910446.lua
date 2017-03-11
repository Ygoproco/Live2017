--ヘル・アライアンス
function c46910446.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c46910446.value)
	c:RegisterEffect(e2)
end
function c46910446.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function c46910446.value(e,c)
	return Duel.GetMatchingGroupCount(c46910446.filter,0,LOCATION_MZONE,LOCATION_MZONE,c,c:GetCode())*800
end
