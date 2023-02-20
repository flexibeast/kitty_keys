kitty_keys () {

    ###
    # kitty_keys: Function to output kitty keybindings.
    ###

    # Convenience function.
    print1 () {
        env printf $1
    }
    
    #
    # User-configurable variables:
    #
    # KITTY_KEYS_LEADING
    # KITTY_KEYS_TRAILING
    # KITTY_KEYS_MAX_WIDTH
    # KITTY_KEYS_CONF
    #
    # Set defaults for these variables if not set in
    # the user's environment.
    #

    # Leading and trailing to use in output.
    # As the output is processed with column(1) using ':' as
    # the delimiter, these variables must contain a ':'. 
    LEADING=${KITTY_KEYS_LEADING:-"\n:\n"}
    TRAILING=${KITTY_KEYS_TRAILING:-":\n"}

    # Maximum column width of action field, after which
    # the action will be displayed as a footnote.
    MAX_WIDTH=${KITTY_KEYS_MAX_WIDTH:-40}

    # Path to kitty configuration file.
    CONF=${KITTY_KEYS_CONF:-~/.config/kitty/kitty.conf}

    #
    # Variables for internal use.
    #
    
    # Try to make field-splitting behaviour uniform across shells.
    local IFS=''
    # Footer for long actions not required by default.
    WANT_FOOTER=no
    
    # Actions with a default keybinding. Based on
    # https://sw.kovidgoyal.net/kitty/actions/
    #
    # Format:
    # section:action:keybinding
    #
    # Vertical pipe, '|', in the keybinding field indicates
    # alternatives to use after the kitty_mod prefix.
    DEFAULTS="\
copypaste:copy_to_clipboard:kitty_mod+c
copypaste:pass_selection_to_program:kitty_mod+o
copypaste:show_last_command_output:kitty_mod+g
copypaste:show_scrollback:kitty_mod+h
copypaste:paste_from_clipboard:kitty_mod+v
copypaste:paste_from_selection:kitty_mod+s
debugging:debug_config:kitty_mod+f6
layouts:next_layout:kitty_mod+l
miscellaneous:send_text:kitty_mod+alt+h
miscellaneous:show_kitty_doc:kitty_mod+f1
miscellaneous:clear_terminal:kitty_mod+delete
miscellaneous:edit_config_file:kitty_mod+f2
miscellaneous:kitty_shell:kitty_mod+escape
miscellaneous:load_config_file:kitty_mod+f5
miscellaneous:open_url_with_hints:kitty_mod+e
scrolling:scroll_end:kitty_mod+end
scrolling:scroll_home:kitty_mod+home
scrolling:scroll_line_down:kitty_mod+down
scrolling:scroll_line_up:kitty_mod+up
scrolling:scroll_page_down:kitty_mod+page_down
scrolling:scroll_page_up:kitty_mod+page_up
scrolling:scroll_to_prompt:kitty_mod+x|z
tabs:close_tab:kitty_mod+q
tabs:move_tab_backward:kitty_mod+,
tabs:move_tab_forward:kitty_mod+.
tabs:new_tab:kitty_mod+t
tabs:next_tab:kitty_mod+right
tabs:previous_tab:kitty_mod+left
tabs:set_tab_title:kitty_mod+alt+t
windows:first_window:kitty_mod+1
windows:second_window:kitty_mod+2
windows:third_window:kitty_mod+3
windows:fourth_window:kitty_mod+4
windows:fifth_window:kitty_mod+5
windows:sixth_window:kitty_mod+6
windows:seventh_window:kitty_mod+7
windows:eighth_window:kitty_mod+8
windows:ninth_window:kitty_mod+9
windows:tenth_window:kitty_mod+0
windows:focus_visible_window:kitty_mod+f7
windows:move_window_backward:kitty_mod+b
windows:move_window_forward:kitty_mod+f
windows:move_window_to_top:kitty_mod+\`
windows:next_window:kitty_mod+]
windows:previous_window:kitty_mod+[
windows:swap_with_window:kitty_mod+f8
windows:change_font_size:kitty_mod+-|=|backspace
windows:close_window:kitty_mod+w
windows:new_os_window:kitty_mod+n
windows:new_window:kitty_mod+enter
windows:set_background_opacity:kitty_mod+a>l|a>1|a>m|a>d
windows:start_resizing_window:kitty_mod+r
windows:toggle_maximized:kitty_mod+f10
"

    #
    # Main logic.
    #
    
    if [ -f "${CONF}" ]
    then
        CHANGES=$(sed -n '/^map/p' "${CONF}" \
                     | sed 's/^map \([^ ]*\) \(.*\)$/custom:\2:\1/')
    else
        CHANGES=''
    fi
    if [ -n "${CHANGES}" ]
    then
        CHANGES=$(print1 ${CHANGES} | \
                  awk -F':' -vw=${MAX_WIDTH} -vn=0 \
                      '{ if (length($2)>w) { \
                            n++; \
                            footer=footer"["n"] "$2"\n"; \
                            print "["n"]:"$3 \
                          } \
                          else { \
                            print $2":"$3 \
                          } \
                       } \
                       END { print "-\n"footer"\n" }')
    fi

    if [ -n "${CHANGES}" ]
    then
        BINDINGS=$(print1 "${CHANGES}" \
                       | awk -F':' '{ print $2 }' | tr '\n' ' ')
        IFS=' '
        for B in $BINDINGS
        do
            if print1 "${DEFAULTS}" | grep -q "${B}"
            then
                DEFAULTS=$(print1 "${DEFAULTS}" | sed "/${B}/d")
            fi
        done
        IFS=''
    fi
    
    COPYPASTE="-- Copy/paste --:
$(print1 ${DEFAULTS} | sed -n 's/^copypaste:\(.*\)$/\1/p')"
    DEBUGGING="-- Debugging --:
$(print1 ${DEFAULTS} | sed -n 's/^debugging:\(.*\)$/\1/p')"
    LAYOUTS="-- Layouts --:
$(print1 ${DEFAULTS} | sed -n 's/^layouts:\(.*\)$/\1/p')"
    MISCELLANEOUS="-- Miscellaneous --:
$(print1 ${DEFAULTS} | sed -n 's/^miscellaneous:\(.*\)$/\1/p')"
    SCROLLING="-- Scrolling --:
$(print1 ${DEFAULTS} | sed -n 's/^copypaste:\(.*\)$/\1/p')"
    TABS="-- Tabs --:
$(print1 ${DEFAULTS} | sed -n 's/^tabs:\(.*\)$/\1/p')"
    WINDOWS="-- Windows --:
$(print1 ${DEFAULTS} | sed -n 's/^windows:\(.*\)$/\1/p')"
    if [ -n "$CHANGES" ]
    then
        CUSTOM="-- Custom --:
$(print1 ${CHANGES} | sed '/^-$/,$d')"
        FOOTER=$(print1 ${CHANGES} | sed -n '/^-$/,$p')
    else
        CUSTOM="${CUSTOM}
[ No key customisations ]"
    fi

    case "${1}" in
        copypaste)
            OUT=${COPYPASTE}
            ;;
        debugging)
            OUT=${DEBUGGING}
            ;;
        layouts)
            OUT=${LAYOUTS}
            ;;
        miscellaneous)
            OUT=${MISCELLANEOUS}
            ;;
        scrolling)
            OUT=${SCROLLING}
            ;;
        tabs)
            OUT=${TABS}
            ;;
        windows)
            OUT=${WINDOWS}
            ;;
        custom)
            OUT=${CUSTOM}
            WANT_FOOTER=yes
            ;;
        *)
            OUT="\
${COPYPASTE}\n${TRAILING}\
${DEBUGGING}\n${TRAILING}\
${LAYOUTS}\n${TRAILING}\
${MISCELLANEOUS}\n${TRAILING}\
${SCROLLING}\n${TRAILING}\
${TABS}\n${TRAILING}\
${WINDOWS}\n${TRAILING}\
${CUSTOM}"
            WANT_FOOTER=yes
            ;;
    esac

    print1 "${LEADING}${OUT}" | column -t -s':'
    if [ "${WANT_FOOTER}" = 'yes' -a -n "${FOOTER}" ]
    then
        print1 "${FOOTER}\n"
    fi
    if [ -n "${TRAILING}" ]
    then
        print1 "${TRAILING}" | column -t -s':'
    fi

    # Remove convenience function from environment.
    unset -f print1
    
}
