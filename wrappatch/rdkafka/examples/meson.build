if host_machine.system() == 'windows'
	win_sources = ['../win32/wingetopt.c', '../win32/wingetopt.h']
else
	win_sources = []
endif

inc = include_directories('../src', '../src-cpp')

executable('producer', ['producer.c'] + win_sources, dependencies: rdkafka_dep, include_directories: inc)
executable('producer_cpp', ['producer.cpp'] + win_sources, dependencies: rdkafkapp_dep, include_directories: inc)
executable('consumer', ['consumer.c'] + win_sources, dependencies: rdkafka_dep, include_directories: inc)
executable('rdkafka_performance', ['rdkafka_performance.c'] + win_sources, dependencies: rdkafka_dep, include_directories: inc)
executable('rdkafka_example_cpp', ['rdkafka_example.cpp'] + win_sources, dependencies: rdkafkapp_dep, include_directories: inc)
executable('rdkafka_complex_consumer_example_cpp', ['rdkafka_complex_consumer_example.cpp'] + win_sources, dependencies: rdkafkapp_dep, include_directories: inc)
executable('openssl_engine_example_cpp', ['openssl_engine_example.cpp'] + win_sources, dependencies: rdkafkapp_dep, include_directories: inc)

# The targets below has Unix include dirs and do not compile on Windows.
if host_machine.system() != 'windows'
	executable('rdkafka_example', ['rdkafka_example.c'] + win_sources, dependencies: rdkafka_dep, include_directories: inc)
	executable('rdkafka_complex_consumer_example', ['rdkafka_complex_consumer_example.c'] + win_sources, dependencies: rdkafka_dep, include_directories: inc)
	executable('kafkatest_verifiable_client', ['kafkatest_verifiable_client.cpp'] + win_sources, dependencies: rdkafkapp_dep, include_directories: inc)
endif

