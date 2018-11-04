/*
Grid check disables all power on the station for a while, notably including lights
It helps to create a feeeling of crisis and community, encouraging people to team up, gather flashlights
and help others. On eris, it also creates a feeling of terror. With no idea how long it'll last, you
become keenly aware of the limited battery supply in your flashlight

All the doors being depowered means that people can crowbar their way into restricted places easily.
So sometimes this event can result in people finding new and interesting things
*/
/datum/storyevent/grid_check
	id = "gridcheck"
	name = "Grid Check"


	event_type = /datum/event/grid_check
	event_pools = list(EVENT_LEVEL_MUNDANE = POOL_THRESHOLD_MUNDANE,
	EVENT_LEVEL_MODERATE = POOL_THRESHOLD_MODERATE)

	tags = list(TAG_SCARY, TAG_COMMUNAL)


///////////////////////////////////////////////////////////////////////

/datum/event/grid_check	//NOTE: Times are measured in master controller ticks!
	announceWhen		= 5

/datum/event/grid_check/start()
	var/strength = 1
	if (severity == EVENT_LEVEL_MODERATE)
		strength = 2
	power_failure(0, strength, maps_data.contact_levels)

/datum/event/grid_check/announce()
	command_announcement.Announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the ship's power will be shut off for an indeterminate duration.", "Automated Grid Check", new_sound = 'sound/AI/poweroff.ogg')



/proc/power_failure(var/announce = 1, var/severity = 2, var/list/affected_z_levels)
	if(announce)
		command_announcement.Announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the ship's power will be shut off for an indeterminate duration.", "Critical Power Failure", new_sound = 'sound/AI/poweroff.ogg')

	for(var/obj/machinery/power/smes/buildable/S in SSmachines.machinery)
		S.energy_fail(rand(10 * severity*severity,20 * severity*severity))


	for(var/obj/machinery/power/apc/C in SSmachines.machinery)
		if(!C.is_critical && (!affected_z_levels || (C.z in affected_z_levels)))
			C.energy_fail(rand(30 * severity*severity,100 * severity*severity))

/proc/power_restore(var/announce = 1)
	var/list/skipped_areas = list(/area/turret_protected/ai)

	if(announce)
		command_announcement.Announce("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal", new_sound = 'sound/AI/poweron.ogg')
	for(var/obj/machinery/power/apc/C in SSmachines.machinery)
		C.failure_timer = 0
		if(C.cell)
			C.cell.charge = C.cell.maxcharge
	for(var/obj/machinery/power/smes/S in SSmachines.machinery)
		var/area/current_area = get_area(S)
		if(current_area.type in skipped_areas)
			continue
		S.failure_timer = 0
		S.charge = S.capacity
		S.update_icon()
		S.power_change()

/proc/power_restore_quick(var/announce = 1)

	if(announce)
		command_announcement.Announce("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal", new_sound = 'sound/AI/poweron.ogg')
	for(var/obj/machinery/power/smes/S in SSmachines.machinery)
		S.failure_timer = 0
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.output_attempt = 1
		S.input_attempt = 1
		S.update_icon()
		S.power_change()