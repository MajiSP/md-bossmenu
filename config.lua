Config = {}
Config.Notify = 'ox' -- qb/ox/okok
Config.OldQB = false -- only select true if you use OLD QB INVENTORY OR OLD PS OR LJ INVENTORY
Config.DefaultCommission = 0.10
Config.JobChatEntry = 'Welcome To Your Boss Menus Job Chat. Please Remember To Follow All Company Protocal! \n Please Remember That Swearing Is A Sin And Not In The Company Policy!'

Config.MenuItems = {
    { icon = 'home', bossOnly = false }, -- home page
    { icon = 'users', bossOnly = true }, -- employees page
    { icon = 'chart-bar', bossOnly = true }, -- stats page
    { icon = 'gift', bossOnly = true }, -- bonuses page
    { icon = 'cog', bossOnly = false } -- settings
}

Config.Locations = { -- add where the boss menu target is
    police =    {    loc = vector3(447.16, -974.31, 30.47),},
    ambulance = {    loc = vector3(311.21, -599.36, 43.29),},
    cardealer = {    loc = vector3(-32.94, -1114.64, 26.42),},
    mechanic =  {    loc = vector3(-347.59, -133.35, 39.01),},
}

Config.Commissions = {
    police = 0.10,
    ambulance = 0.10,
    cardealer = 0.05,
    mechanic = 0.15,
}
