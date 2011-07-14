#! /usr/bin/env python
# encoding: utf-8
# Markus Schulz, 2011

# the following two variables are used by the target "waf dist"
VERSION = '0.0.1'
APPNAME = 'HEH2011'

# these variables are mandatory ('/' are converted automatically)
srcdir = '.'
blddir = 'build'

def set_options(opt):
	opt.tool_options('compiler_cc')

def configure(conf):
	conf.check_tool('compiler_cc cc vala')
	conf.setenv('default')
    	conf.env.CCFLAGS = ['-O2']
	conf.check_cfg(package='glib-2.0', uselib_store='GLIB', atleast_version='2.10.0', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='gtk+-2.0', uselib_store='GTK', atleast_version='2.10.0', mandatory=1, args='--cflags --libs')
    
	# create the second environment, set the variant and set its name
	env = conf.env.copy()
	env.set_variant('debug')
	conf.set_env_name('debug', env)

	# call the debug environment
	conf.setenv('debug')
	conf.env['VALAFLAGS'] = ['-g']
	conf.env.CCFLAGS = ['-O0', '-g3']

def build(bld):
	bld.add_subdirs('src')
	bld.install_files('${PREFIX}/doc', 'README')
