module Main exposing (main)

import Browser
import Dict
--import Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Task

type alias DrinkType = String
type alias DrinkSpec =
    { volume: Float
    , ethanol: Float
    , acid: Float
    , sugar: Float
    }
drinkTypeToSpec : Dict.Dict DrinkType DrinkSpec
drinkTypeToSpec =
    Dict.fromList [
        ( "Built Drink", { volume = 2.5, ethanol= 37, acid= 0, sugar= 9.5 } ),
        ( "Stirred Drink", { volume = 3, ethanol= 36, acid= 0.175, sugar= 6.7 } ),
        ("Shaken Drink", { volume = 3.5, ethanol=27.25, acid=1.3, sugar=10.75 } ),
        ("Blended Drink", { volume = 0.75, ethanol=30.5, acid=1.085, sugar=15.2 } )
    ]

type alias Recipe = (String, List Float)
type RecipeResult
    = RecipeSuccess Recipe
    | RecipeFailure

type alias Model =
    { fieldIngredients : Dict.Dict String Bool
    , recipe : Maybe (List String, RecipeResult)
    }

type alias Ingredient = String

type alias IngredientProperties =
    { ethanol: Float
    , acidity: Float
    , sugar: Float
    }
zeroIngredientProperties : IngredientProperties
zeroIngredientProperties = { ethanol=0, acidity=0, sugar=0 }

chooseRecipe : RecipeResult -> RecipeResult -> RecipeResult
chooseRecipe r1 r2 =
    case (r1, r2) of
        (RecipeFailure, RecipeFailure) -> RecipeFailure
        (RecipeFailure, RecipeSuccess s) -> RecipeSuccess s
        (RecipeSuccess s, _) -> RecipeSuccess s

ingredientToProperties : Dict.Dict Ingredient IngredientProperties
ingredientToProperties =
    Dict.fromList [
        ( "Carpano Antica Formula", { ethanol = 16.500000, sugar = 16.000000, acidity = 0.600000 } ),
        ( "Dolan Blanc", { ethanol = 16.000000, sugar = 13.000000, acidity = 0.600000 } ),
        ( "Dolin Dry", { ethanol = 17.500000, sugar = 3.000000, acidity = 0.600000 } ),
        ( "Dolin Rouge", { ethanol = 16.000000, sugar = 13.000000, acidity = 0.600000 } ),
        ( "Generic dry vermouth", { ethanol = 17.500000, sugar = 3.000000, acidity = 0.600000 } ),
        ( "Generic sweet vermouth", { ethanol = 16.500000, sugar = 16.000000, acidity = 0.600000 } ),
        ( "Lillet Blanc", { ethanol = 17.000000, sugar = 9.500000, acidity = 0.600000 } ),
        ( "Martinelli", { ethanol = 16.000000, sugar = 10.000000, acidity = 0.600000 } ),
        ( "Amaro CioCiaro", { ethanol = 30.000000, sugar = 16.000000, acidity = 0.000000 } ),
        ( "Amer Picon", { ethanol = 15.000000, sugar = 20.000000, acidity = 0.000000 } ),
        ( "Aperol", { ethanol = 11.000000, sugar = 24.000000, acidity = 0.000000 } ),
        ( "Benedictine", { ethanol = 40.000000, sugar = 24.500000, acidity = 0.000000 } ),
        ( "Campari", { ethanol = 24.000000, sugar = 24.000000, acidity = 0.000000 } ),
        ( "Chartreuse, Green", { ethanol = 55.000000, sugar = 25.000000, acidity = 0.000000 } ),
        ( "Chartreuse, Yellow", { ethanol = 40.000000, sugar = 31.200000, acidity = 0.000000 } ),
        ( "Cointreau", { ethanol = 40.000000, sugar = 25.000000, acidity = 0.000000 } ),
        ( "Crême de cacao, white", { ethanol = 24.000000, sugar = 39.500000, acidity = 0.000000 } ),
        ( "Crême de violette", { ethanol = 20.000000, sugar = 37.500000, acidity = 0.000000 } ),
        ( "Drambuie", { ethanol = 40.000000, sugar = 30.000000, acidity = 0.000000 } ),
        ( "Fernet Branca", { ethanol = 39.000000, sugar = 8.000000, acidity = 0.000000 } ),
        ( "Luxardo Maraschino", { ethanol = 32.000000, sugar = 35.000000, acidity = 0.000000 } ),
        ( "Angostura", { ethanol = 44.700000, sugar = 4.200000, acidity = 0.000000 } ),
        ( "Peychauds", { ethanol = 35.000000, sugar = 5.000000, acidity = 0.000000 } ),
        ( "Ashmead's Kernel apple", { ethanol = 0.000000, sugar = 14.700000, acidity = 1.250000 } ),
        ( "Concord grape", { ethanol = 0.000000, sugar = 18.000000, acidity = 0.500000 } ),
        ( "Cranberry", { ethanol = 0.000000, sugar = 13.300000, acidity = 3.500000 } ),
        ( "Granny Smith apple", { ethanol = 0.000000, sugar = 13.000000, acidity = 0.930000 } ),
        ( "Grapefruit", { ethanol = 0.000000, sugar = 10.400000, acidity = 2.400000 } ),
        ( "Honeycrisp apple", { ethanol = 0.000000, sugar = 13.800000, acidity = 0.660000 } ),
        ( "Orange", { ethanol = 0.000000, sugar = 12.400000, acidity = 0.800000 } ),
        ( "Strawberry", { ethanol = 0.000000, sugar = 8.000000, acidity = 1.500000 } ),
        ( "Wickson", { ethanol = 0.000000, sugar = 14.700000, acidity = 1.250000 } ),
        ( "Champagne acid", { ethanol = 0.000000, sugar = 0.000000, acidity = 6.000000 } ),
        ( "Lemon juice", { ethanol = 0.000000, sugar = 1.600000, acidity = 6.000000 } ),
        ( "Lime acid orange", { ethanol = 0.000000, sugar = 0.000000, acidity = 6.000000 } ),
        ( "Lime juice", { ethanol = 0.000000, sugar = 1.600000, acidity = 6.000000 } ),
        ( "Orange juice, lime strength", { ethanol = 0.000000, sugar = 12.400000, acidity = 6.000000 } ),
        ( "70 Brix caramel syrup", { ethanol = 0.000000, sugar = 61.500000, acidity = 0.000000 } ),
        ( "Butter syrup", { ethanol = 0.000000, sugar = 42.100000, acidity = 0.000000 } ),
        ( "Coriander syrup", { ethanol = 0.000000, sugar = 61.500000, acidity = 0.000000 } ),
        ( "Demerara syrup", { ethanol = 0.000000, sugar = 61.500000, acidity = 0.000000 } ),
        ( "Djer syrup", { ethanol = 0.000000, sugar = 61.500000, acidity = 0.000000 } ),
        ( "Honey syrup", { ethanol = 0.000000, sugar = 61.500000, acidity = 0.000000 } ),
        ( "Maple syrup", { ethanol = 0.000000, sugar = 87.500000, acidity = 0.000000 } ),
        ( "Any nut orgeat", { ethanol = 0.000000, sugar = 61.500000, acidity = 0.000000 } ),
        ( "Commercial orgeat", { ethanol = 0.000000, sugar = 85.500000, acidity = 0.000000 } ),
        ( "Quinine simple syrup", { ethanol = 0.000000, sugar = 61.500000, acidity = 0.000000 } ),
        ( "Simple syrup", { ethanol = 0.000000, sugar = 61.500000, acidity = 0.000000 } ),
        ( "Cabernet sauvignon", { ethanol = 14.500000, sugar = 0.200000, acidity = 0.560000 } ),
        ( "Coconut water", { ethanol = 0.000000, sugar = 6.000000, acidity = 0.000000 } ),
        ( "Espresso", { ethanol = 0.000000, sugar = 0.000000, acidity = 1.500000 } ),
        ( "Sour orange juice", { ethanol = 0.000000, sugar = 12.300000, acidity = 4.500000 } ),
        ( "Café Zacapa", { ethanol = 31.000000, sugar = 0.000000, acidity = 0.750000 } ),
        ( "Chocolate Vodka", { ethanol = 40.000000, sugar = 0.000000, acidity = 0.000000 } ),
        ( "Jalapeño Tequila", { ethanol = 40.000000, sugar = 0.000000, acidity = 0.000000 } ),
        ( "Lemongrass Vodka", { ethanol = 40.000000, sugar = 0.000000, acidity = 0.000000 } ),
        ( "Milk-Washed Rum", { ethanol = 34.000000, sugar = 0.000000, acidity = 0.000000 } ),
        ( "Peanut Butter and Jelly Vodka", { ethanol = 32.500000, sugar = 16.500000, acidity = 0.250000 } ),
        ( "Sugared 100 proof", { ethanol = 44.000000, sugar = 18.500000, acidity = 0.000000 } ),
        ( "Sugared 80 proof", { ethanol = 35.000000, sugar = 18.500000, acidity = 0.000000 } ),
        ( "Tea Vodka", { ethanol = 34.000000, sugar = 0.000000, acidity = 0.000000 } ),
        ( "Turmeric Gin", { ethanol = 41.200000, sugar = 0.000000, acidity = 0.000000 } )
    ]

type alias RecipeRequest =
    { i1: IngredientProperties
    , i2: IngredientProperties
    , i3: IngredientProperties
    , i4: IngredientProperties
    }

recipeRequestWithDrinkTypeToRecipe : DrinkType -> DrinkSpec -> RecipeRequest -> RecipeResult
recipeRequestWithDrinkTypeToRecipe dt ds request =
    let
        { i1, i2, i3, i4 } = request
        e1 = i1.ethanol
        a1=i1.acidity
        s1=i1.sugar
        e2=i2.ethanol
        a2=i2.acidity
        s2=i2.sugar
        e3=i3.ethanol
        a3=i3.acidity
        s3=i3.sugar
        e4=i4.ethanol
        a4=i4.acidity
        s4=i4.sugar
        tv = ds.volume
        e=ds.ethanol
        a=ds.acid
        s=ds.sugar
        v1 = -((tv*(a3*e2*s - a4*e2*s - a2*e3*s + a4*e3*s + a2*e4*s - a3*e4*s + a*e3*s2 - a4*e3*s2 - a*e4*s2 + a3*e4*s2 - a*e2*s3 + a4*e2*s3 + a*e4*s3 - a2*e4*s3 + a*e2*s4 - a3*e2*s4 - a*e3*s4 + a2*e3*s4 + a2*a4*s*tv - a3*a4*s*tv - a*a3*s2*tv + a3*a4*s2*tv + a*a2*s3*tv - a2*a4*s3*tv - a*a2*s4*tv + a*a3*s4*tv))/(-(a3*e2*s1) + a4*e2*s1 + a2*e3*s1 - a4*e3*s1 - a2*e4*s1 + a3*e4*s1 + a3*e1*s2 - a4*e1*s2 - a1*e3*s2 + a4*e3*s2 + a1*e4*s2 - a3*e4*s2 - a2*e1*s3 + a4*e1*s3 + a1*e2*s3 - a4*e2*s3 - a1*e4*s3 + a2*e4*s3 + a2*e1*s4 - a3*e1*s4 - a1*e2*s4 + a3*e2*s4 + a1*e3*s4 - a2*e3*s4 - a2*a4*s1*tv + a3*a4*s1*tv + a1*a4*s2*tv - a3*a4*s2*tv - a1*a4*s3*tv + a2*a4*s3*tv))
        v2 = (tv*(a3*e1*s - a4*e1*s - a1*e3*s + a4*e3*s + a1*e4*s - a3*e4*s + a*e3*s1 - a4*e3*s1 - a*e4*s1 + a3*e4*s1 - a*e1*s3 + a4*e1*s3 + a*e4*s3 - a1*e4*s3 + a*e1*s4 - a3*e1*s4 - a*e3*s4 + a1*e3*s4 + a1*a4*s*tv - a3*a4*s*tv - a*a3*s1*tv + a3*a4*s1*tv + a*a1*s3*tv - a1*a4*s3*tv - a*a1*s4*tv + a*a3*s4*tv))/(-(a3*e2*s1) + a4*e2*s1 + a2*e3*s1 - a4*e3*s1 - a2*e4*s1 + a3*e4*s1 + a3*e1*s2 - a4*e1*s2 - a1*e3*s2 + a4*e3*s2 + a1*e4*s2 - a3*e4*s2 - a2*e1*s3 + a4*e1*s3 + a1*e2*s3 - a4*e2*s3 - a1*e4*s3 + a2*e4*s3 + a2*e1*s4 - a3*e1*s4 - a1*e2*s4 + a3*e2*s4 + a1*e3*s4 - a2*e3*s4 - a2*a4*s1*tv + a3*a4*s1*tv + a1*a4*s2*tv - a3*a4*s2*tv - a1*a4*s3*tv + a2*a4*s3*tv)
        v3 = -((tv*(a2*e1*s - a4*e1*s - a1*e2*s + a4*e2*s + a1*e4*s - a2*e4*s + a*e2*s1 - a4*e2*s1 - a*e4*s1 + a2*e4*s1 - a*e1*s2 + a4*e1*s2 + a*e4*s2 - a1*e4*s2 + a*e1*s4 - a2*e1*s4 - a*e2*s4 + a1*e2*s4 + a1*a4*s*tv - a2*a4*s*tv - a*a2*s1*tv + a2*a4*s1*tv + a*a1*s2*tv - a1*a4*s2*tv - a*a1*s4*tv + a*a2*s4*tv))/(-(a3*e2*s1) + a4*e2*s1 + a2*e3*s1 - a4*e3*s1 - a2*e4*s1 + a3*e4*s1 + a3*e1*s2 - a4*e1*s2 - a1*e3*s2 + a4*e3*s2 + a1*e4*s2 - a3*e4*s2 - a2*e1*s3 + a4*e1*s3 + a1*e2*s3 - a4*e2*s3 - a1*e4*s3 + a2*e4*s3 + a2*e1*s4 - a3*e1*s4 - a1*e2*s4 + a3*e2*s4 + a1*e3*s4 - a2*e3*s4 - a2*a4*s1*tv + a3*a4*s1*tv + a1*a4*s2*tv - a3*a4*s2*tv - a1*a4*s3*tv + a2*a4*s3*tv))
        v4 = (tv*(-(a2*e1*s) + a3*e1*s + a1*e2*s - a3*e2*s - a1*e3*s + a2*e3*s - a*e2*s1 + a3*e2*s1 + a*e3*s1 - a2*e3*s1 + a*e1*s2 - a3*e1*s2 - a*e3*s2 + a1*e3*s2 - a*e1*s3 + a2*e1*s3 + a*e2*s3 - a1*e2*s3 + a*a2*s1*tv - a*a3*s1*tv - a*a1*s2*tv + a*a3*s2*tv + a*a1*s3*tv - a*a2*s3*tv))/(a3*e2*s1 - a4*e2*s1 - a2*e3*s1 + a4*e3*s1 + a2*e4*s1 - a3*e4*s1 - a3*e1*s2 + a4*e1*s2 + a1*e3*s2 - a4*e3*s2 - a1*e4*s2 + a3*e4*s2 + a2*e1*s3 - a4*e1*s3 - a1*e2*s3 + a4*e2*s3 + a1*e4*s3 - a2*e4*s3 - a2*e1*s4 + a3*e1*s4 + a1*e2*s4 - a3*e2*s4 - a1*e3*s4 + a2*e3*s4 + a2*a4*s1*tv - a3*a4*s1*tv - a1*a4*s2*tv + a3*a4*s2*tv + a1*a4*s3*tv - a2*a4*s3*tv)
    in
        if v1 >= 0 && v2 >= 0 && v3 >= 0 && v4 >= 0
        then RecipeSuccess (dt, [v1, v2, v3, v4])
        else RecipeFailure

recipeRequestToRecipe : RecipeRequest -> RecipeResult
recipeRequestToRecipe request =
    List.foldl chooseRecipe RecipeFailure ((List.map ( \ (dt, ds) -> recipeRequestWithDrinkTypeToRecipe dt ds request) (Dict.toList drinkTypeToSpec)))

ingredientsToRecipe : (List IngredientProperties) -> RecipeResult
ingredientsToRecipe ingredients =
    case ingredients of
        [] -> RecipeFailure
        [i1] -> recipeRequestToRecipe { i1=i1, i2=zeroIngredientProperties, i3=zeroIngredientProperties, i4=zeroIngredientProperties }
        [i1,i2] -> recipeRequestToRecipe { i1=i1, i2=i2, i3=zeroIngredientProperties, i4=zeroIngredientProperties }
        [i1,i2,i3] -> recipeRequestToRecipe { i1=i1, i2=i2, i3=i3, i4=zeroIngredientProperties }
        i1 :: i2 :: i3 :: i4 :: _ -> recipeRequestToRecipe { i1=i1, i2=i2, i3=i3, i4=i4 }

ingredientNamesToRecipe : (List Ingredient) -> RecipeResult
ingredientNamesToRecipe is =
    let
        props = List.map (\i -> Dict.get i ingredientToProperties) is
        extractMaybe l = case l of
            [] -> Just []
            Nothing :: _ -> Nothing
            (Just e) :: rest -> case extractMaybe rest of
                Nothing -> Nothing
                Just otherwise -> Just (e :: otherwise)
        p = extractMaybe props
    in case p of
        Nothing -> RecipeFailure
        Just otherwise -> ingredientsToRecipe otherwise

init : Model
init =
    { fieldIngredients = Dict.map (\i _ -> False) ingredientToProperties
    , recipe = Nothing
    }

type Msg
    = NoOp
    | SubmitForm
    | ToggleIngredient Ingredient

update : Msg -> Model -> Model
update msg model =
    case msg of
        SubmitForm ->
            ( { model | recipe = Just (filteredIngredients model.fieldIngredients, ingredientNamesToRecipe (filteredIngredients model.fieldIngredients)) } )
        NoOp ->
            ( model )
        ToggleIngredient ingredient ->
            ( { model | fieldIngredients = toggle ingredient model.fieldIngredients } )

toggle : comparable -> Dict.Dict comparable Bool -> Dict.Dict comparable Bool
toggle key dict =
    Dict.update key
        (\oldValue ->
            case oldValue of
                Just value ->
                    Just <| not value
                Nothing ->
                    Nothing
        )
        dict

filteredIngredients : Dict.Dict comparable Bool -> List comparable
filteredIngredients ingredients =
    Dict.keys
        (Dict.filter (\key value -> value) ingredients)

maxIngredientSelectable : Int
maxIngredientSelectable =
    4

ingredientsQuantityHaveReachedtheLimit : Dict.Dict comparable Bool -> Bool
ingredientsQuantityHaveReachedtheLimit ingredients =
    List.length (filteredIngredients ingredients) >= maxIngredientSelectable

onEnter : msg -> Attribute msg
onEnter msg =
    keyCode
        |> Decode.andThen
            (\key ->
                if key == 13 then
                    Decode.succeed msg
                else
                    Decode.fail "Not enter"
            )
        |> on "keyup"

zip l1 l2 = case (l1, l2) of
    ([], _) -> []
    (_, []) -> []
    (a :: as_, b :: bs) -> (a, b) :: (zip as_ bs)

-- VIEWS

view : Model -> Html Msg
view = viewForm
    
viewForm : Model -> Html Msg
viewForm model =
    div [ class "form-container" ]
        [ div
            [ onEnter SubmitForm
            ]
            [ node "style" [] [ text "" ]
            , div [ class "checkboxContainer" ]
                (List.map
                    (\ingredient ->
                        let
                            value =
                                Dict.get ingredient model.fieldIngredients

                            isDisabled =
                                ingredientsQuantityHaveReachedtheLimit model.fieldIngredients && not (Maybe.withDefault False value)

                            isChecked =
                                Maybe.withDefault False value
                        in
                        label
                            [ classList
                                [ ( "checkbox", True )
                                , ( "disabled", isDisabled )
                                , ( "checked", isChecked )
                                ]
                            ]
                            [ input
                                [ type_ "checkbox"
                                , checked isChecked
                                , disabled isDisabled
                                , onClick <| ToggleIngredient ingredient
                                ]
                                []
                            , text <| " " ++ ingredient
                            ]
                    )
                    (Dict.keys
                        model.fieldIngredients
                    )
                )
            , div [ class "formMessage" ]
                [ text <|
                    "Select up to "
                        ++ String.fromInt maxIngredientSelectable
                        ++ " ingredients - Selected: "
                        ++ String.fromInt (List.length <| filteredIngredients model.fieldIngredients)
                ]
            , button
                [ onClick SubmitForm
                , classList
                    [ ( "disabled", List.isEmpty (filteredIngredients model.fieldIngredients )) ]
                ]
                [ text "Submit" ]
            , div [ class "formMessage" ]
              [ text <|
                  case model.recipe of
                      Nothing -> ""
                      Just (_, RecipeFailure) -> "Could not make a recipe with the given ingredients"
                      Just (is, RecipeSuccess (name, proportions)) ->
                          let
                              ingredientProps = zip is proportions
                          in
                              "Make a " ++ name ++ " with " ++
                              String.join ", " (List.map (\ (i, prop) -> String.fromFloat prop ++ "oz " ++ i) ingredientProps)
              ]
            ]
        ]
    
-- MAIN

main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }