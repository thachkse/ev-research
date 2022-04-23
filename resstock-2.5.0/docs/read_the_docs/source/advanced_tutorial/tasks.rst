Tasks
=====

Run tasks.rb
------------

Use ``openstudio tasks.rb update_measures`` to apply rubocop auto-correct to measures, and to update measure.xml files.

.. _using-the-rakefile:

Using the Rakefile
------------------

Once you have completed instructions found in :doc:`installer_setup`, you can then use the `Rakefile <https://github.com/NREL/resstock/blob/develop/Rakefile>`_ contained at the top level of this repository. You will run rake task(s) for :ref:`performing integrity checks on project inputs <integrity-checks>`.

Run ``rake -T`` to see the list of possible rake tasks. The ``-T`` is replaced with the chosen task.

.. code:: bash

  $ rake -T
  rake integrity_check_all         # Run tests for integrity_check_all
  rake integrity_check_national    # Run tests for integrity_check_national  
  rake integrity_check_testing     # Run tests for integrity_check_testing   
  rake integrity_check_unit_tests  # Run tests for integrity_check_unit_tests
  rake test:analysis_tests         # Run tests for analysis_tests
  rake test:project_tests          # Run tests for project_tests
  rake test:regenerate_osms        # Run tests for regenerate_osms
  rake test:unit_tests             # Run tests for unit_tests

.. _integrity-checks:

Integrity Checks
----------------

Run ``rake integrity_check_<project_name>``, where ``<project_name>`` matches the project you are working with. If no rake task exists for the project you are working with, extend the list of integrity check rake tasks to accommodate your project by copy-pasting and renaming the ``integrity_check_national`` rake task found in the `Rakefile <https://github.com/NREL/resstock/blob/develop/Rakefile>`_. An example for running a project's integrity checks is given below:

.. code:: bash

  $ rake integrity_check_national
  Checking for issues with project_national/Location Region...
  Checking for issues with project_national/Location EPW...
  Checking for issues with project_national/Vintage...
  Checking for issues with project_national/Heating Fuel...
  Checking for issues with project_national/Usage Level...
  ...

If the integrity check for a given project fails, you will need to update either your tsv files and/or the ``resources/options_lookup.tsv`` file. See :doc:`options_lookup` for information about the ``options_lookup.tsv`` file.