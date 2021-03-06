create or replace package body test_ut_suite is

  procedure cleanup_package_state is
  begin
    ut_example_tests.g_number := null;
  end;

  procedure disabled_suite is
    l_suite    ut3.ut_suite;
  begin
    --Arrange
    l_suite := ut3.ut_suite(a_object_owner => USER, a_object_name => 'UT_EXAMPLE_TESTS');
    l_suite.path := 'ut_example_tests';
    l_suite.disabled_flag := ut3.ut_utils.boolean_to_int(true);
    l_suite.before_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'set_g_number_0', ut3.ut_utils.gc_before_all));
    l_suite.after_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'add_1_to_g_number', ut3.ut_utils.gc_before_all));
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number'));
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number'));
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut_example_tests.g_number).to_be_null;
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_disabled);
    ut.expect(l_suite.results_count.disabled_count).to_equal(2);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(0);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(0);
  end;

  procedure beforeall_errors is
    l_suite    ut3.ut_suite;
  begin
    --Arrange
    l_suite := ut3.ut_suite(a_object_owner => USER, a_object_name => 'UT_EXAMPLE_TESTS');
    l_suite.path := 'ut_example_tests';
    l_suite.before_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'failing_procedure', ut3.ut_utils.gc_before_all));
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'set_g_number_0'));
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut_example_tests.g_number).to_be_null;
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(l_suite.results_count.disabled_count).to_equal(0);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(0);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(1);
  end;

  procedure aftereall_errors is
    l_suite    ut3.ut_suite;
  begin
    --Arrange
    l_suite := ut3.ut_suite(a_object_owner => USER, a_object_name => 'UT_EXAMPLE_TESTS');
    l_suite.path := 'ut_example_tests';
    l_suite.after_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_EXAMPLE_TESTS', 'failing_procedure', ut3.ut_utils.gc_after_all));

    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'set_g_number_0'));
    l_suite.add_item(ut3.ut_test(a_object_name => 'UT_EXAMPLE_TESTS',a_name => 'add_1_to_g_number'));
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut_example_tests.g_number).to_equal(1);
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_success);
    ut.expect(l_suite.results_count.disabled_count).to_equal(0);
    ut.expect(l_suite.results_count.warnings_count).to_equal(1);
    ut.expect(l_suite.results_count.success_count).to_equal(2);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(0);
  end;

  procedure package_without_body is
    l_suite    ut3.ut_suite;
  begin
    l_suite := ut3.ut_suite(a_object_owner => USER, a_object_name => 'UT_WITHOUT_BODY');
    l_suite.path := 'UT_WITHOUT_BODY';
    l_suite.add_item(ut3.ut_test(a_object_name => 'ut_without_body',a_name => 'test1'/*, a_rollback_type => ut3.ut_utils.gc_rollback_auto*/));
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_error);
  end;

  procedure package_with_invalid_body is
    l_suite    ut3.ut_suite;
  begin
    l_suite := ut3.ut_suite(a_object_owner => USER, a_object_name => 'UT_WITH_INVALID_BODY');
    l_suite.path := 'UT_WITH_INVALID_BODY';
    l_suite.add_item(ut3.ut_test(a_object_name => 'ut_with_invalid_body',a_name => 'test1'/*, a_rollback_type => ut3.ut_utils.gc_rollback_auto*/));
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_error);
  end;

  procedure test_rollback_type(a_procedure_name varchar2, a_rollback_type integer, a_expectation ut3_latest_release.ut_matcher) is
    l_suite    ut3.ut_suite;
  begin
    --Arrange
    execute immediate 'delete from ut$test_table';
    l_suite := ut3.ut_suite(a_object_owner => USER, a_object_name => 'UT_TRANSACTION_CONTROL');
    l_suite.path := 'ut_transaction_control';
    l_suite.before_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'UT_TRANSACTION_CONTROL', 'setup', ut3.ut_utils.gc_before_all));
    l_suite.add_item(ut3.ut_test(a_object_owner => USER, a_object_name => 'ut_transaction_control',a_name => a_procedure_name));
    l_suite.set_rollback_type(a_rollback_type);

    --Act
    l_suite.do_execute();

    --Assert
    ut.expect(core.get_value(q'[ut_transaction_control.count_rows('t')]')).to_( a_expectation );
    ut.expect(core.get_value(q'[ut_transaction_control.count_rows('s')]')).to_( a_expectation );
  end;

  procedure rollback_auto is
  begin
    test_rollback_type('test', ut3.ut_utils.gc_rollback_auto, equal(0) );
  end;

  procedure rollback_auto_on_failure is
  begin
    test_rollback_type('test_failure', ut3.ut_utils.gc_rollback_auto, equal(0) );
  end;

  procedure rollback_manual is
  begin
    test_rollback_type('test', ut3.ut_utils.gc_rollback_manual, be_greater_than(0) );
  end;

  procedure rollback_manual_on_failure is
  begin
    test_rollback_type('test_failure', ut3.ut_utils.gc_rollback_manual, be_greater_than(0) );
  end;
end;
/