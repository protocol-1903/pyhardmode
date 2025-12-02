py.on_event(py.events.on_init(), function()
    remote.call("pywiki", "add_section", "hardmode")

    remote.call("pywiki", "add_page", {
        name = "heat",
        section = "hardmode",
        text_only = true
    })
end)