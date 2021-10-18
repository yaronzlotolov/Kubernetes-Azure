using Employees.Models;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Employees.Models
{
    public static class ModelBuilderExtentions
    {
        //* part 51 step 9-10 for extention method (ModelBuilder) the class should be static
        public static void Seed(this ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Employee>().HasData(
               new Employee
               {
                   Id = 1,
                   Name = "Oded Katash",
                   Role = Dept.PointGuard,
                   Email = "oded@gmail.com"
               },
               new Employee
               {
                   Id = 2,
                   Name = "Doron Shefer",
                   Role = Dept.SmallForward,
                   Email = "doron@gmail.com"
               },
               new Employee
               {
                   Id = 3,
                   Name = "Omri Casspi",
                   Role = Dept.PowerForward,
                   Email = "omri@gmail.com"
               }
            );
        }
    }
}
