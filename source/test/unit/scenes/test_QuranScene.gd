extends "res://test/BaseIntegrationTest.gd"

###
# TODO: maybe we should remove this test.
# QuranScene instantiates/calls CreditsScene, which causes the test runner
# to display weird visual quirks. /shrug
###
func test_play_next_ayah_eventually_calls_on_complete():
	var scene = partial_double("res://Scenes/QuranScene.tscn").instance()
	
	# Choice is important because we call get_node(...) based on this name
	scene.set_ayaat(["quran-intro-1", "quran-intro-2"])
	stub(scene, "_display_current_ayah")
	stub(scene, "_on_complete")
	
	add_child(scene)
	
	scene._play_next_ayah()
	assert_not_called(scene, "_on_complete")
	scene._play_next_ayah()
	yield(yield_for(1.1), YIELD)
	assert_called(scene, "_on_complete")