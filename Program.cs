using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;

namespace IdentifyCategories
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");
            var portfolio = new List<ITrade>()
            {
                new Trade(2000000, "Private"),
                new Trade(400000, "Public"),
                new Trade(500000, "Public"),
                new Trade(3000000, "Public"),
                //new Trade(100_000, "Private"),
            };


            var rules = Logic.loadCategory();
            /*
                Input:
                Trade1 {Value = 2000000; ClientSector = "Private"}
                Trade2 {Value = 400000; ClientSector = "Public"}
                Trade3 {Value = 500000; ClientSector = "Public"}
                Trade4 {Value = 3000000; ClientSector = "Public"}
                portfolio = {Trade1, Trade2, Trade3, Trade4}
                Output:
                tradeCategories = {"HIGHRISK", "LOWRISK", "LOWRISK", "MEDIUMRISK"}
                */
            var result = Logic.VerifyRisk(rules, portfolio);
        }

        #region Logica/Obtenção de dados
        public class Logic
        {
            public static List<CategoryRules> loadCategory()
            {
                List<CategoryRules> items = new List<CategoryRules>();
                string path = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), @"File\CategoryRules.json");
                using (StreamReader r = new StreamReader(path))
                {
                    string json = r.ReadToEnd();
                    items = JsonConvert.DeserializeObject<List<CategoryRules>>(json);
                }
                return items;
            }

            public static List<string> VerifyRisk(List<CategoryRules> rules, List<ITrade> trades)
            {
                List<string> lst = new List<string>();

                foreach (var trade in trades)
                {
                    bool find = false;
                    foreach (var rule in rules)
                    {
                        if (compareTradeRule(rule, trade))
                        {
                            lst.Add(rule.CategoryName);
                            find = true;
                        }
                    }
                    if (!find)
                    {
                        lst.Add("UNKNOWN RISK");
                    }
                }

                return lst;
            }

            public static bool compareTradeRule(CategoryRules rule, ITrade trade)
            {
                if (trade.ClientSector == rule.Client)
                {
                    switch (rule.Conditional)
                    {
                        case ConditionalRule.LessThan:
                            if (trade.Value < rule.Value)
                            {
                                return true;
                            }
                            break;
                        case ConditionalRule.GreaterThen:
                            if (trade.Value > rule.Value)
                            {
                                return true;
                            }
                            break;
                        default:
                            break;
                    }
                }

                return false;
            }

        }
        #endregion

        #region Classes/Interfaces
        public class CategoryRules
        {
            public string CategoryName { get; set; }
            public string Client { get; set; }
            public double Value { get; set; }
            public ConditionalRule Conditional { get; set; }
        }

        public enum ConditionalRule
        {
            LessThan,
            GreaterThen
        }

        public interface ITrade
        {
            double Value { get; }
            string ClientSector { get; }
        }

        public class Trade : ITrade
        {
            public Trade(
                 double value,
                 string clientSector)
            {
                Value = value;
                ClientSector = clientSector;
            }
            public double Value { get; private set; }
            public string ClientSector { get; private set; }
            public string Risk { get; private set; }
        }

        #endregion
    }
}
