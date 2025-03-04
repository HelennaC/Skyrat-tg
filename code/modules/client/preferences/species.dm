/// Species preference
/datum/preference/choiced/species
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "species"
	priority = PREFERENCE_PRIORITY_SPECIES
	randomize_by_default = FALSE

/datum/preference/choiced/species/deserialize(input, datum/preferences/preferences)
	return GLOB.species_list[sanitize_inlist(input, get_choices_serialized(), "human")]

/datum/preference/choiced/species/serialize(input)
	var/datum/species/species = input
	return initial(species.id)

/datum/preference/choiced/species/create_default_value()
	return /datum/species/human

/datum/preference/choiced/species/create_random_value(datum/preferences/preferences)
	return pick(get_choices())

/datum/preference/choiced/species/init_possible_values()
	var/list/values = list()

	for (var/species_id in get_selectable_species())
		values += GLOB.species_list[species_id]

	return values

/datum/preference/choiced/species/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/prefs)
	target.set_species(value, FALSE, prefs?.features.Copy(), prefs?.mutant_bodyparts.Copy(), prefs?.body_markings.Copy())

//SKYRAT EDIT ADDITION
	target.dna.update_body_size()

	for(var/organ_key in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_PENIS, ORGAN_SLOT_BREASTS))
		var/obj/item/organ/genital/gent = target.getorganslot(organ_key)
		if(gent)
			gent.aroused = prefs.arousal_preview
			gent.update_sprite_suffix()

	if(prefs && length(prefs.augments))
		for(var/key in prefs.augments)
			var/datum/augment_item/aug = GLOB.augment_items[prefs.augments[key]]
			aug.apply(target, prefs = prefs)
//SKYRAT EDIT END

/datum/preference/choiced/species/compile_constant_data()
	var/list/data = list()

	var/list/food_flags = FOOD_FLAGS

	for (var/species_id in get_selectable_species())
		var/species_type = GLOB.species_list[species_id]
		var/datum/species/species = new species_type

		var/list/diet = list()

		if (!(TRAIT_NOHUNGER in species.inherent_traits))
			diet = list(
				"liked_food" = bitfield2list(species.liked_food, food_flags),
				"disliked_food" = bitfield2list(species.disliked_food, food_flags),
				"toxic_food" = bitfield2list(species.toxic_food, food_flags),
			)

		data[species_id] = list(
			"name" = species.name,
			"icon" = sanitize_css_class_name(species.name),

			"use_skintones" = species.use_skintones,
			"sexes" = species.sexes,

			"enabled_features" = species.get_features(),
		) + diet

	return data
