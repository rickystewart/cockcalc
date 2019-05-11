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

type alias Recipe = Dict.Dict String Float
type RecipeResult
    = RecipeSuccess Recipe
    | RecipeFailure

type alias Model =
    { fieldIngredients : Dict.Dict String Bool
    , recipe : Maybe RecipeResult
    }

type alias Ingredient = String

type alias IngredientProperties =
    { ethanol: Float
    , acidity: Float
    , sugar: Float
    }

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
            ( model )
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
                    "Select "
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