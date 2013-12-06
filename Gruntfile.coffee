module.exports = (grunt) ->

    grunt.task.loadNpmTasks 'grunt-contrib-watch'
    grunt.task.loadNpmTasks 'grunt-mocha-test'
    grunt.task.loadNpmTasks 'grunt-coffeelint'
    grunt.task.loadNpmTasks 'grunt-clear'

    grunt.initConfig
        pkg: 
            grunt.file.readJSON('package.json')

        watch:
            dev:
                files: ['src/**/*.coffee', 'test/**/*.coffee']
                tasks: ['clear', 'coffeelint:dev', 'mochaTest:dist']

        coffeelint:
            dev:
                files:
                    src: ['src/**/*.coffee']
            dist:
                files:
                    src: ['src/**/*.coffee']
            options:
                no_tabs: #using tabs!
                    level: 'ignore'
                indentation: #using tabs screws this right up
                    level: 'ignore'
                max_line_length: #I trust you
                    level: 'ignore'

        mochaTest:
            dist:
                options:
                    ui: 'bdd'
                    reporter: 'nyan'
                src:
                    'test/**/*.coffee'

    grunt.event.on 'coffee.error', (msg) ->
        grunt.log.write msg

    grunt.registerTask 'build', ['coffeelint:dev']
    grunt.registerTask 'test', ['coffeelint:dev', 'mochaTest']
    grunt.registerTask 'default', ['coffeelint:dev', 'mochaTest']
    grunt.registerTask 'dev', ['watch:dev']