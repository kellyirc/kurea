module.exports = (grunt) ->

    grunt.task.loadNpmTasks 'grunt-contrib-coffee'
    grunt.task.loadNpmTasks 'grunt-contrib-watch'
    grunt.task.loadNpmTasks 'grunt-contrib-jshint'
    grunt.task.loadNpmTasks 'grunt-contrib-uglify'
    grunt.task.loadNpmTasks 'grunt-mocha-test'

    grunt.initConfig
        pkg: 
            grunt.file.readJSON('package.json')

        coffee:
            dist:
                src: ['src/core/*.coffee']
                dest: '<%= pkg.name %>.js'

        watch:
            dist:
                files: '<%= coffee.dist.src %>'
                tasks: [ 'coffee:dist', 'jshint:dist', 'mochaTest:dist', 'uglify:dist' ]

        jshint:
            options:
                '-W040': true #possible strict violation -- can't get around this with coffeescript
                '-W097': true #use strict -- we're not going to use strict
                '-W117': true #undefined variable for exports
                '-W041': true #use !== to compare with null - coffee generates != when using ?
                '-W093': true #did you mean to return a conditional? no, I wanted to run a statement

            dist:
                ['<%= pkg.name %>.js']

        mochaTest:
            dist:
                options:
                    ui: 'bdd'
                    reporter: 'nyan'
                src:
                    'test/**/*.coffee'

        uglify:
            dist:
                options:
                    sourceMap: '<%= pkg.name %>.js'
                files:
                    '<%= pkg.name %>.min.js': '<%= pkg.name %>.js'

    grunt.event.on 'coffee.error', (msg) ->
        grunt.log.write msg

    grunt.registerTask 'test', ['coffee', 'jshint', 'mochaTest']
    grunt.registerTask 'default', ['coffee', 'jshint', 'mochaTest', 'uglify']
    grunt.registerTask 'dev', ['watch']