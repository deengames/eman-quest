extends "res://test/BaseIntegrationTest.gd"

const AlphaFluctuator = preload("res://Scripts/Effects/AlphaFluctuator.gd")

func test_run_yields_after_specified_time():
	# Arrange
	var target = Sprite.new()
	var fluctuator = AlphaFluctuator.new(target)
	watch_signals(fluctuator)
	
	# Act
	fluctuator.run(0.1) # expire after 0.1s
	fluctuator.start()
	fluctuator._process(0.2) # 0.2s elapse!
	
	# Assert
	assert_signal_emitted(fluctuator, "done")