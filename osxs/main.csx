#! "netcoreapp2.1"
#r "nuget: PushBulletSharp, 3.1.0"

//#############################################################################################################################
// dotnet script : pushbullet example
// example: 
// dotnet script https://tinyurl.com/ya5chql8 -- o.tZCHwg4A9C124ba2tFiiZDf1SaHzxJzC test "message to phone"  1>&2 || echo "no"
//#############################################################################################################################


using PushbulletSharp;
using PushbulletSharp.Filters;
using PushbulletSharp.Models.Requests;
using PushbulletSharp.Models.Responses;

if (Args.Count() < 3)
{
    Console.WriteLine($"Example to use : {Environment.NewLine} dotnet script https://tinyurl.com/osx-pushbullet -- o.tZCHwg4A9C124ba2tFiiZDfs1sSaHzsxJsdzC test \"message to phone\"");
}

var token = Args[0];
var title = Args[1];
var message = Args[2];

var client = new PushbulletClient(token);

try
{
    //If you don't know your device_iden, you can always query your devices
    var devices = client.CurrentUsersDevices();

    var device = devices.Devices.Where(o => o.Icon == "phone").FirstOrDefault();

    if (device != null)
    {
        var request = new PushNoteRequest
        {
            Title = title,
            Body = message
        };

        var response = client.PushNote(request);
        Console.WriteLine($"{response.Iden}");
        return response.Dismissed ? -1 : 0;
    }
}
catch (System.Exception)
{
    return -1;
}