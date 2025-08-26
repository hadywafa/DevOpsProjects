using Microsoft.AspNetCore.Mvc;
using Company.Utils;

namespace Consumer.App.Controllers;

public class HomeController : Controller
{
    public IActionResult Index()
    {
        var original = "Hello from Azure Artifacts and Company.Utils!";
        var firstFive = StringTools.TakeFirst(original, 5);
        ViewData["Original"] = original;
        ViewData["FirstFive"] = firstFive;
        return View();
    }
}
